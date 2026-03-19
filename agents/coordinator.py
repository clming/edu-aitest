#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Coordinator Agent - 项目总管理

教育类应用开发项目的总协调员
负责任务分解、Agent 调度、结果整合

作者：OpenClaw (二爷的助手)
创建时间：2026-03-19
"""

import json
import os
from datetime import datetime
from typing import Dict, List, Any, Optional


class CoordinatorAgent:
    """项目总协调 Agent"""
    
    def __init__(self, config_path: str = None):
        """初始化 Coordinator"""
        self.config_path = config_path or os.path.join(
            os.path.dirname(__file__), 'coordinator.json'
        )
        self.config = self._load_config()
        self.sub_agents = self._init_sub_agents()
        self.project_state = {
            "status": "initialized",
            "current_task": None,
            "completed_tasks": [],
            "messages": []
        }
        
    def _load_config(self) -> Dict:
        """加载配置文件"""
        with open(self.config_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def _init_sub_agents(self) -> Dict[str, Dict]:
        """初始化子 Agent 配置"""
        agents = {}
        agents_dir = os.path.dirname(__file__)
        
        for agent_id in self.config.get('subAgents', []):
            config_file = os.path.join(agents_dir, f'{agent_id}.json')
            if os.path.exists(config_file):
                with open(config_file, 'r', encoding='utf-8') as f:
                    agents[agent_id] = json.load(f)
                    
        return agents
    
    def analyze_request(self, user_request: str) -> Dict[str, Any]:
        """
        分析用户需求
        
        Args:
            user_request: 用户请求文本
            
        Returns:
            分析结果，包含需要的 Agent 列表和任务分解
        """
        # 关键词匹配路由
        routing_map = {
            'product': ['产品', '需求', '功能', '设计', '原型', 'UI', 'UX'],
            'planning': ['计划', '排期', '任务', '分解', '架构'],
            'development': ['开发', '编码', '实现', '代码', '程序'],
            'testing': ['测试', 'bug', '缺陷', '质量']
        }
        
        required_agents = []
        keywords_found = []
        
        for category, keywords in routing_map.items():
            for keyword in keywords:
                if keyword.lower() in user_request.lower():
                    if category not in keywords_found:
                        keywords_found.append(category)
        
        # 根据类别映射到 Agent
        agent_mapping = {
            'product': 'product-manager',
            'planning': 'project-manager',
            'development': 'developer',
            'testing': 'qa-engineer'
        }
        
        for category in keywords_found:
            agent = agent_mapping.get(category)
            if agent and agent not in required_agents:
                required_agents.append(agent)
        
        # 默认至少需要 product-manager 和 project-manager
        if not required_agents:
            required_agents = ['product-manager', 'project-manager']
        
        return {
            "required_agents": required_agents,
            "keywords": keywords_found,
            "complexity": self._estimate_complexity(user_request),
            "estimated_time": self._estimate_time(user_request)
        }
    
    def _estimate_complexity(self, request: str) -> str:
        """估算任务复杂度"""
        length = len(request)
        if length < 50:
            return "low"
        elif length < 200:
            return "medium"
        else:
            return "high"
    
    def _estimate_time(self, request: str) -> int:
        """估算完成时间 (分钟)"""
        complexity = self._estimate_complexity(request)
        time_map = {
            "low": 30,
            "medium": 60,
            "high": 120
        }
        return time_map.get(complexity, 60)
    
    def dispatch_task(self, agent_id: str, task: Dict) -> Dict:
        """
        分发任务给子 Agent
        
        Args:
            agent_id: Agent ID
            task: 任务详情
            
        Returns:
            Agent 执行结果
        """
        if agent_id not in self.sub_agents:
            return {
                "success": False,
                "error": f"Agent {agent_id} not found"
            }
        
        agent_config = self.sub_agents[agent_id]
        
        # 构建 Agent 的系统提示
        system_prompt = agent_config.get('systemPrompt', '')
        
        # 这里应该调用实际的 Agent 执行
        # 由于是配置演示，返回模拟结果
        return {
            "success": True,
            "agent_id": agent_id,
            "task": task,
            "status": "dispatched",
            "timestamp": datetime.now().isoformat()
        }
    
    def collect_results(self, results: List[Dict]) -> Dict:
        """
        收集并整合各 Agent 的结果
        
        Args:
            results: 各 Agent 的执行结果列表
            
        Returns:
            整合后的结果
        """
        integrated = {
            "status": "completed",
            "timestamp": datetime.now().isoformat(),
            "results_count": len(results),
            "results": results,
            "summary": self._generate_summary(results)
        }
        
        return integrated
    
    def _generate_summary(self, results: List[Dict]) -> str:
        """生成结果摘要"""
        success_count = sum(1 for r in results if r.get('success', False))
        total = len(results)
        
        return f"完成任务：{success_count}/{total}"
    
    def execute(self, user_request: str) -> Dict:
        """
        执行完整的工作流
        
        Args:
            user_request: 用户请求
            
        Returns:
            最终结果
        """
        print(f"🎯 Coordinator 接收请求：{user_request[:100]}...")
        
        # 1. 分析需求
        analysis = self.analyze_request(user_request)
        print(f"📊 需求分析：需要 {len(analysis['required_agents'])} 个 Agent")
        
        # 2. 分发任务
        results = []
        for agent_id in analysis['required_agents']:
            print(f"📤 分发任务给：{agent_id}")
            result = self.dispatch_task(agent_id, {
                "request": user_request,
                "analysis": analysis
            })
            results.append(result)
        
        # 3. 收集结果
        final_result = self.collect_results(results)
        print(f"✅ 任务完成：{final_result['summary']}")
        
        # 4. 更新状态
        self.project_state['status'] = 'completed'
        self.project_state['completed_tasks'].append({
            "request": user_request,
            "timestamp": datetime.now().isoformat(),
            "result": final_result
        })
        
        return final_result
    
    def get_status(self) -> Dict:
        """获取项目状态"""
        return self.project_state
    
    def save_state(self, path: str = None):
        """保存项目状态"""
        path = path or 'project_state.json'
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(self.project_state, f, indent=2, ensure_ascii=False)


def main():
    """主函数 - 演示用法"""
    coordinator = CoordinatorAgent()
    
    # 示例请求
    request = """
    我需要做一个教育类的 iOS APP + Android APP + WEB 端，
    对应需要设计一个 APP 的服务管理后台。
    参考应用：作业帮家长版
    技术选型：Flutter + Go
    """
    
    # 执行
    result = coordinator.execute(request)
    
    # 保存状态
    coordinator.save_state()
    
    print("\n" + "="*50)
    print("Coordinator 执行完成")
    print("="*50)
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
