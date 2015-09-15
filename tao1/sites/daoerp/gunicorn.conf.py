
worker_class ='aiohttp.worker.GunicornWebWorker'
bind='127.0.0.1:8080'
workers=8
reload=True
user = "nobody"

