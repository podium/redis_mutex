import Config

config :redis_mutex, env: config_env()

import_config "./#{config_env()}.exs"
