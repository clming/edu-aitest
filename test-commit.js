/**
 * 测试提交文件
 * 
 * 用途：验证 Git 提交功能是否正常
 * 创建时间：2026-03-19
 * 创建人：二爷的项目
 */

// 简单的测试函数
function testCommit() {
  const message = "Git 提交测试成功！";
  const timestamp = new Date().toISOString();
  
  console.log("=".repeat(50));
  console.log("🎉 Git 提交测试");
  console.log("=".repeat(50));
  console.log(`消息：${message}`);
  console.log(`时间：${timestamp}`);
  console.log(`项目：edu-aitest`);
  console.log(`仓库：https://github.com/clming/edu-aitest`);
  console.log("=".repeat(50));
  console.log("✅ 测试通过！");
  console.log("");
  
  // 🐛 BUG: 这里故意制造一个除零错误
  const testValue = 100 / 0;
  console.log(`测试值：${testValue}`);
  
  // 🐛 BUG: 这里故意访问未定义的变量
  console.log(`未定义变量：${undefinedVariable}`);
  
  return {
    success: true,
    message: message,
    timestamp: timestamp,
    project: "edu-aitest"
  };
}

// 运行测试
testCommit();

// 导出函数供其他模块使用
module.exports = { testCommit };
