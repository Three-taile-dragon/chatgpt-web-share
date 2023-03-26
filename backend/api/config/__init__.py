import os
import shutil
import yaml
import re

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper


class Config:
    def __init__(self, config_file):
        # 如果缺少配置文件，则复制模板并创建文件
        if not os.path.exists(config_file):
            if os.path.exists(config_file + ".template"):
                shutil.copyfile(config_file + ".template", config_file)
        with open(config_file, 'r') as f:
            self.config = yaml.load(f, Loader=Loader)
        self.apply_replacements()

    def get(self, key, default=None):
        return self.config.get(key, default)

    def set(self, key, value):
        self.config[key] = value

    def save(self, config_file):
        with open(config_file, 'w') as f:
            yaml.dump(self.config, f)
    def apply_replacements(self):
        self.config = replace_env_variables(self.config)

def replace_env_variables(config):
    for key, value in config.items():
        if isinstance(value, str):
            matches = re.findall(r'{{\s*([\w\d_]+)\s*}}', value)
            if matches:
                for match in matches:
                    env_value = os.environ.get(match, '')
                    value = value.replace('{{' + match + '}}', env_value)
                config[key] = value
        elif isinstance(value, dict):
            config[key] = replace_env_variables(value)
    return config

            
config_file = os.path.join(os.path.dirname(__file__), "config.yaml")
config = Config(config_file)

