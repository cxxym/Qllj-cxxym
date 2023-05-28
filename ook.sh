#!/bin/bash
#作者 panxiao
# 判断是否root执行
if [ `id -u` -ne 0 ];then
# 开始计时
start_time=$(date +%s.%N)
# 创建一个文件来储存白名单中的文件名
touch whitelist.txt
# 获取白名单列表的行数及所有文件数量
white_lines=$(cat whitelist.txt | wc -l)
all_files=$(ls -A /storage/emulated/0 | wc -l)
# 设置删除计数和删除记录文件路径
deleted=0
log_path="/sdcard/deleted_files.log"
# 定义并发线程数
thread_num=10
# 在日志文件中写入当前时间和操作说明
#echo "$(date '+%Y-%m-%d %H:%M:%S') - 删除非白名单文件" >> $log_path
# 遍历所有文件并删除非白名单文件
for file_name in $(ls -a /storage/emulated/0); do
  # 如果文件不在白名单中，则删除
  if ! grep -q "$file_name" whitelist.txt; then
    ((deleted++))
# 在新线程中删除文件
  {
    rm -rf "/storage/emulated/0/$file_name"
    echo "$deleted=>删除$file_name"
    #echo "$(date '+%Y-%m-%d %H:%M:%S') - 删除文件：$file_name" >> $log_path
  } &
  # 控制并发线程数量
  while [ $(jobs | wc -l) -ge $thread_num ]; do
      sleep 1
    done
  fi
done
# 等待所有线程结束
wait
# 停止计时
end_time=$(date +%s.%N)
elapsed=$(echo "$end_time - $start_time" | bc)
# 格式化时间，确保输出3位数
formatted_time=$(printf "%.3f" $elapsed)
# 输出删除统计信息和完成提示
echo "删除完成！共删除了 $deleted 个文件用时$formatted_time秒（不包括白名单中的文件）"
echo "详细记录请查看：$log_path"
# 如果为root执行则提示并退出脚本
   else
    i=0
    while ((i<=20)) do
      ((i++))
      echo "禁止使用root运行-此操作可能使设备变砖!"
    done
fi
