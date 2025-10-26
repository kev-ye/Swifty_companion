"""
profile.py - 个人资料页面
"""
from kivy.uix.screenmanager import Screen
from kivy.uix.scrollview import ScrollView
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.gridlayout import GridLayout
from kivy.uix.label import Label
from kivy.uix.button import Button
from kivy.uix.image import AsyncImage


class ProfileScreen(Screen):
    def __init__(self, **kwargs):
        super(ProfileScreen, self).__init__(**kwargs)
        
        # 主布局
        main_layout = BoxLayout(orientation='vertical', padding=10, spacing=10)
        
        # 顶部安全区域（为刘海屏留空间）
        top_spacer = BoxLayout(size_hint=(1, None), height='50dp')
        main_layout.add_widget(top_spacer)
        
        # 滚动视图
        scroll = ScrollView(size_hint=(1, 1))
        self.content_layout = BoxLayout(
            orientation='vertical',
            spacing=10,
            size_hint_y=None,
            padding=10
        )
        self.content_layout.bind(minimum_height=self.content_layout.setter('height'))
        scroll.add_widget(self.content_layout)
        main_layout.add_widget(scroll)
        
        # 返回按钮（固定在底部）
        back_btn = Button(
            text='< Back',
            size_hint=(1, None),
            height='48dp'  # 使用 dp 单位适应不同屏幕密度
        )
        back_btn.bind(on_press=self.go_back)
        main_layout.add_widget(back_btn)
        
        # 底部安全区域（为 iPhone 底部手势区域留空间）
        bottom_spacer = BoxLayout(size_hint=(1, None), height='30dp')
        main_layout.add_widget(bottom_spacer)
        
        self.add_widget(main_layout)
    
    def go_back(self, instance):
        self.manager.current = 'search'
    
    def load_user_data(self, user_data):
        # 清空之前的内容
        self.content_layout.clear_widgets()
        
        # 头像
        if user_data.get('image') and user_data['image'].get('link'):
            avatar = AsyncImage(
                source=user_data['image']['link'],
                size_hint=(1, None),
                height=200
            )
            self.content_layout.add_widget(avatar)
        
        # 基本信息
        self.add_section_title('Basic Information')
        
        info_items = [
            ('Login', user_data.get('login', 'N/A')),
            ('Email', user_data.get('email', 'N/A')),
            ('Display Name', user_data.get('displayname', 'N/A')),
            ('Phone', user_data.get('phone', 'N/A')),
            ('Location', user_data.get('location', 'N/A')),
            ('Wallet', str(user_data.get('wallet', 'N/A'))),
            ('Correction Points', str(user_data.get('correction_point', 'N/A'))),
        ]
        
        for label, value in info_items:
            self.add_info_row(label, value)
        
        # Campus 信息
        if user_data.get('campus'):
            self.add_section_title('Campus')
            for campus in user_data['campus']:
                self.add_info_row('Name', campus.get('name', 'N/A'))
                self.add_info_row('Time Zone', campus.get('time_zone', 'N/A'))
        
        # Cursus 和 Level
        if user_data.get('cursus_users'):
            self.add_section_title('Cursus and Level')
            for cursus in user_data['cursus_users']:
                cursus_info = cursus.get('cursus', {})
                self.add_info_row('Cursus', cursus_info.get('name', 'N/A'))
                self.add_info_row('Level', f"{cursus.get('level', 0):.2f}")
                self.add_info_row('Grade', str(cursus.get('grade', 'N/A')))
        
        # Skills
        if user_data.get('cursus_users'):
            for cursus in user_data['cursus_users']:
                if cursus.get('skills'):
                    self.add_section_title('Skills')
                    for skill in cursus['skills']:
                        skill_name = skill.get('name', 'Unknown')
                        skill_level = skill.get('level', 0)
                        # 分解为等级和百分比
                        level_int = int(skill_level)
                        level_percentage = int((skill_level - level_int) * 100)
                        self.add_info_row(skill_name, f"Level {level_int} ({level_percentage}%)")
        
        # Projects (只显示 finished 的项目)
        if user_data.get('projects_users'):
            self.add_section_title('Projects')
            finished_projects = []
            
            for project in user_data['projects_users']:
                status = project.get('status', '').lower()
                # 只显示 finished 的项目
                if status == 'finished':
                    proj_info = project.get('project', {})
                    proj_name = proj_info.get('name', 'Unknown')
                    final_mark = project.get('final_mark', 'N/A')
                    validated = project.get('validated?', False)
                    
                    status_text = f"{proj_name}"
                    if final_mark != 'N/A':
                        status_text += f" - {final_mark}"
                    
                    self.add_project_row(status_text, validated)
                    finished_projects.append(project)
            
            # 如果没有 finished 的项目
            if not finished_projects:
                self.add_label('No finished projects')
        else:
            self.add_section_title('Projects')
            self.add_label('No projects found')
    
    def add_section_title(self, title):
        label = Label(
            text=f'\n{title}',
            size_hint=(1, None),
            font_size='18sp',
            bold=True,
            halign='left',
            valign='top'
        )
        # 绑定宽度到 text_size，允许自动换行
        label.bind(width=lambda instance, value: setattr(instance, 'text_size', (value, None)))
        # 根据 texture_size 自动调整高度
        label.bind(texture_size=lambda instance, value: setattr(instance, 'height', value[1] + 10))
        self.content_layout.add_widget(label)
    
    def add_info_row(self, label_text, value_text):
        row = BoxLayout(
            orientation='horizontal',
            size_hint=(1, None),
            spacing=10
        )
        
        label = Label(
            text=f'{label_text}:',
            size_hint=(0.4, None),
            halign='right',
            valign='top'
        )
        # 自动调整高度和换行
        label.bind(width=lambda instance, value: setattr(instance, 'text_size', (value, None)))
        label.bind(texture_size=lambda instance, value: setattr(instance, 'height', value[1]))
        
        value_label = Label(
            text=str(value_text),
            size_hint=(0.6, None),
            halign='left',
            valign='top'
        )
        # 自动调整高度和换行
        value_label.bind(width=lambda instance, value: setattr(instance, 'text_size', (value, None)))
        value_label.bind(texture_size=lambda instance, value: setattr(instance, 'height', value[1]))
        
        row.add_widget(label)
        row.add_widget(value_label)
        
        # 让 row 的高度适应最高的子元素
        def update_row_height(*args):
            row.height = max(label.height, value_label.height) + 5
        
        value_label.bind(height=update_row_height)
        label.bind(height=update_row_height)
        
        self.content_layout.add_widget(row)
    
    def add_project_row(self, text, validated):
        label = Label(
            text=text,
            size_hint=(1, None),
            halign='left',
            valign='top',
            # validated=True 显示绿色，validated=False 显示红色
            color=(0, 1, 0, 1) if validated else (1, 0, 0, 1)
        )
        # 自动调整高度和换行
        label.bind(width=lambda instance, value: setattr(instance, 'text_size', (value, None)))
        label.bind(texture_size=lambda instance, value: setattr(instance, 'height', value[1] + 5))
        self.content_layout.add_widget(label)
    
    def add_label(self, text):
        label = Label(
            text=text,
            size_hint=(1, None),
            halign='left',
            valign='top'
        )
        # 自动调整高度和换行
        label.bind(width=lambda instance, value: setattr(instance, 'text_size', (value, None)))
        label.bind(texture_size=lambda instance, value: setattr(instance, 'height', value[1] + 5))
        self.content_layout.add_widget(label)

