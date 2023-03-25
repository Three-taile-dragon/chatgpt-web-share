import os
import shutil
import yaml

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

    def get(self, key, default=None):
        return self.config.get(key, default)

    def set(self, key, value):
        self.config[key] = value

    def save(self, config_file):
        with open(config_file, 'w') as f:
            yaml.dump(self.config, f)

def replace_env_variables(config):
    for key, value in config.items():
        if isinstance(value, str):
            config[key] = value.replace('{{', '{').replace('}}', '}').format(**os.environ)
        elif isinstance(value, dict):
            config[key] = replace_env_variables(value)
    return config
            
            
           
config_file = os.path.join(os.path.dirname(__file__), "config.yaml")
config = Config(config_file)
config = replace_env_variables(config)
