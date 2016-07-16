from setuptools import setup, find_packages
import sys, os


# version = __import__(tao1).__version__

if sys.version_info < (3, 5, 0):
    raise RuntimeError("tao1 requires Python 3.5.1+")

setup(name='tao1',
      version="0.2.5",
      description=("framework, CMS and CRM for aiohttp and asyncio"),
#      lond_description='\n\n'.join((read('README.rst'), read('CHANGES.txt'))),

      scripts=['tao1/core/utils.py'],
      classifiers=[
          'Intended Audience :: Developers',
          'Programming Language :: Python',
          'Programming Language :: Python :: 3.5',
          'Topic :: Internet :: WWW/HTTP'],
      author="Alexandre Z",
      author_email="alikzao@gmail.com",
      url='https://github.com/alikzao/tao',
      license='MIT',
      packages=find_packages(),
      install_requires=['aiohttp==0.20.2', 'aiohttp_jinja2', 'aiohttp_debugtoolbar', 'pymongo', 'aiomcache',
                        'aiohttp_session', 'aiohttp_autoreload'],
      include_package_data=True
    )
      
      
      
      
      

