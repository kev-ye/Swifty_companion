"""
search.py - 搜索页面
"""
from kivy.uix.screenmanager import Screen
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.clock import Clock
from threading import Thread
import api


class SearchScreen(Screen):
    def __init__(self, **kwargs):
        super(SearchScreen, self).__init__(**kwargs)
        
        # 主布局
        layout = BoxLayout(orientation='vertical', padding=20, spacing=10)
        
        # 顶部安全区域（为刘海屏留空间）
        top_spacer = BoxLayout(size_hint=(1, None), height='50dp')
        layout.add_widget(top_spacer)
        
        # 标题
        title = Label(
            text='42 Swifty Companion',
            size_hint=(1, None),
            height='80dp',
            font_size='24sp'
        )
        layout.add_widget(title)
        
        # 输入框
        self.login_input = TextInput(
            hint_text='Enter login name',
            multiline=False,
            size_hint=(1, None),
            height='48dp',
            font_size='16sp'
        )
        self.login_input.bind(on_text_validate=self.on_search)
        layout.add_widget(self.login_input)
        
        # 错误信息标签（支持自动换行）
        self.error_label = Label(
            text='',
            size_hint=(1, 1),
            color=(1, 0, 0, 1),
            halign='center',
            valign='middle',
            font_size='14sp'
        )
        # 绑定宽度以支持自动换行
        self.error_label.bind(width=lambda instance, value: setattr(instance, 'text_size', (value, None)))
        layout.add_widget(self.error_label)
        
        # 搜索按钮（固定在底部）
        search_btn = Button(
            text='Search',
            size_hint=(1, None),
            height='48dp',
            font_size='16sp'
        )
        search_btn.bind(on_press=self.on_search)
        layout.add_widget(search_btn)
        
        # 底部安全区域（为 iPhone 底部手势区域留空间）
        bottom_spacer = BoxLayout(size_hint=(1, None), height='30dp')
        layout.add_widget(bottom_spacer)
        
        self.add_widget(layout)
    
    def on_search(self, instance):
        login = self.login_input.text.strip()
        if not login:
            self.error_label.text = 'Please enter a login name'
            return
        
        self.error_label.text = 'Loading...'
        self.error_label.color = (1, 1, 1, 1)
        
        # 在后台线程中获取数据
        Thread(target=self.fetch_user_data, args=(login,), daemon=True).start()
    
    def fetch_user_data(self, login):
        try:
            user_data = api.get_user(login)
            # 使用默认参数来捕获变量，避免闭包问题
            Clock.schedule_once(lambda dt, data=user_data: self.show_profile(data), 0)
        except Exception as e:
            # 先转换为字符串，避免闭包问题
            error_msg = str(e)
            Clock.schedule_once(lambda dt: self.show_error(error_msg), 0)
    
    def show_error(self, error_msg):
        self.error_label.text = f'Error: {error_msg}'
        self.error_label.color = (1, 0, 0, 1)
    
    def show_profile(self, user_data):
        profile_screen = self.manager.get_screen('profile')
        profile_screen.load_user_data(user_data)
        self.manager.current = 'profile'
        self.error_label.text = ''
        self.login_input.text = ''

