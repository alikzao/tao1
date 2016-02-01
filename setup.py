from setuptools import setup, find_packages
import sys, os, re


# version = __import__(tao1).__version__

if sys.version_info < (3, 4, 1):
    raise RuntimeError("tao1 requires Python 3.4.1+")

setup(name='tao1',
      version="0.1.8.3",
      description=("framework, CMS and CRM for aiohttp"),
#      lond_description='\n\n'.join((read('README.rst'), read('CHANGES.txt'))),

      scripts=['tao1/core/utils.py'],
      classifiers=[
          'Intended Audience :: Developers',
          'Programming Language :: Python',
          'Programming Language :: Python :: 3.4',
          'Topic :: Internet :: WWW/HTTP'],
      author="Alexandre Z",
      author_email="alikzao@gmail.com",
      url='https://github.com/alikzao/tao',
      license='MIT',
      packages=find_packages(),
      install_requires=['aiohttp', 'aiohttp_jinja2', 'aiohttp_debugtoolbar', 'pymongo', 'aiomcache'],
#      tests_require=tests_require,
#      test_suite='nose.collector',
      include_package_data=True
    )
      
      
      
      
      

