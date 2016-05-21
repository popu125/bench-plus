# bench-plus
魔改版bench.sh,原版官网[http://bench.sh](http://bench.sh)。

## 修改内容
1. 更改测速文件为Google（基本代表VPS直连Youtube速度）+Aliyun（代表连接国内速度）+Tsinghua（代表教育网速度）
2. 增加本地测速功能，可自动统计计算出本地到VPS大体的速度值。
3. 分步显示速度测试结果，让你漫长的等待显得短一些。

## 普通测速模式使用指南
普通测速，执行`wget sh.bobiji.com/bench.sh -qO - | bash`即可。稍等片刻即出结果。

## 增加本地测速的测速模式
1. 执行`wget sh.bobiji.com/bench.sh -qO - | localTest=Y bash`，并等到屏幕上出现“Please download file from http://$serverip:8000/botest.”（$serverip会被脚本替换为你的VPS的公网IP）的提示时，访问脚本提供的url，下载一个10M的测速文件。
2. 下载完成后等待片刻即出结果。

## TODO
[] 选择本地测速文件大小（很简单但懒得写了）
