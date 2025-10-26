"""
main.py - 主程序入口
"""
from kivy.app import App
from kivy.uix.screenmanager import ScreenManager, Screen, SlideTransition

from pages.search import SearchScreen
from pages.profile import ProfileScreen


class SwiftyCompanionApp(App):
    def build(self):
        # 创建屏幕管理器
        sm = ScreenManager()
        
        # 添加搜索页面
        search_screen = SearchScreen(name='search')
        sm.add_widget(search_screen)
        
        # 添加个人资料页面
        profile_screen = ProfileScreen(name='profile')
        sm.add_widget(profile_screen)
        
        return sm


if __name__ == '__main__':
    SwiftyCompanionApp().run()