require 'redis'

Redis.current = Redis.new(
    url: Figaro.env.redis_url,
    port: Figaro.env.redis_port,
    password: Figaro.env.redis_password,
    db: Figaro.env.redis_db
)