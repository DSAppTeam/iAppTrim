const fs = require('fs');
const path = require('path');
const https = require('https');
const URL = require('url').URL;
const EventEmitter = require('events');
const err = msg => new EventEmitter().emit('error', msg);
var allDecreaseSize = 0;
var compressTime = 0;
const conf = {
    files: [],
    EntryFolder: process.argv[2],
    DeepLoop: true,
    Exts: ['.jpg', '.png'],
    Max: 5200000, // 5MB == 5242848.754299136
}

fileFilter(conf.EntryFolder)
var compressTotalTime = conf.files.length;
console.log("等待压缩图片的数量:", conf.files.length)

conf.files.forEach(img => fileUpload(img));

//////////////////////////////// 工具函数

/**
 * 过滤待处理文件夹，得到待处理文件列表
 * @param {*} folder 待处理文件夹
 * @param {*} files 待处理文件列表
 */
function fileFilter(folder) {
    // 读取文件夹
    fs.readdirSync(folder).forEach(file => {
        let fullFilePath = path.join(folder, file)
        // 读取文件信息
        let fileStat = fs.statSync(fullFilePath);
        // 过滤文件安全性/大小限制/后缀名
        if (fileStat.size <= conf.Max && fileStat.isFile() && conf.Exts.includes(path.extname(file))) conf.files.push(fullFilePath);
        // 是都要深度递归处理文件夹
        else if (conf.DeepLoop && fileStat.isDirectory()) fileFilter(fullFilePath);
    });
}

/**
 * TinyPng 远程压缩 HTTPS 请求的配置生成方法
 */

function getAjaxOptions() {
    return {
        method: 'POST',
        hostname: 'tinypng.com',
        path: '/backend/opt/shrink',
        headers: {
            rejectUnauthorized: false,
            "X-Forwarded-For": Array(4).fill(1).map(() => parseInt(Math.random() * 254 + 1)).join('.'),
            'Postman-Token': Date.now(),
            'Cache-Control': 'no-cache',
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36'
        }
    }
}

/**
 * TinyPng 远程压缩 HTTPS 请求
 * @param {string} img 待处理的文件
 * @success {
 *              "input": { "size": 887, "type": "image/png" },
 *              "output": { "size": 785, "type": "image/png", "width": 81, "height": 81, "ratio": 0.885, "url": "https://tinypng.com/web/output/7aztz90nq5p9545zch8gjzqg5ubdatd6" }
 *           }
 * @error  {"error": "Bad request", "message" : "Request is invalid"}
 */
function fileUpload(imgPath) {
    let req = https.request(getAjaxOptions(), (res) => {
        res.on('data', buf => {
            let obj = JSON.parse(buf.toString());
            if (obj.error) {
                compressTime += 1;
                console.log(`压缩失败！\n 当前文件：${imgPath} \n ${obj.message}`);
            } else {
                fileUpdate(imgPath, obj);
            }
        });
    });

    req.write(fs.readFileSync(imgPath), 'binary');
    req.on('error', e => console.error(`请求错误! \n 当前文件：${imgPath} \n, e`));
    req.end();
}

// 该方法被循环调用,请求图片数据
function fileUpdate(entryImgPath, obj) {
    let options = new URL(obj.output.url);
    let req = https.request(options, res => {
        let body = '';
        res.setEncoding('binary');
        res.on('data', (data) => body += data);
        res.on('end', () => {
            fs.writeFile(entryImgPath, body, 'binary', err => {
                compressTime += 1;
                if (err) {
                    if (compressTime == compressTotalTime && compressTotalTime != -1) {
                        console.log(`--------压缩已结束--------累计缩减大小=${ allDecreaseSize.toFixed(2) }KB`)
                    }
                    return console.error(err);
                }
                let log = "压缩成功"
                log += `文件=${entryImgPath}🔨`
                log += `原始文件大小=${ (obj.input.size / 1024).toFixed(2) }KB🔨`
                log += `压缩后文件大小=${ (obj.output.size / 1024).toFixed(2) }KB🔨`
                log += `缩减大小=${ ((obj.input.size - obj.output.size) / 1024).toFixed(2) }KB🔨`
                log += `优化比例=${ (( 1 - obj.output.ratio) * 100).toFixed(2) }%🔨`
                allDecreaseSize += ((obj.input.size - obj.output.size) / 1024);
                console.log(log);
                if (compressTime == compressTotalTime && compressTotalTime != -1) {
                    compressTotalTime = -1
                    console.log(`--------压缩已结束--------累计缩减大小=${ allDecreaseSize.toFixed(2) }KB`)
                }
            });
        });
    });
    req.on('error', e => console.error(e));
    req.end();
}

