from setuptools import setup, find_packages
import os, re


# version = __import__(tao1).__version__

setup(name='tao1',
      version="0.1.7.8",
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
      install_requires=['aiohttp', 'aiohttp_jinja2', 'aiohttp_debugtoolbar', 'pymongo'],
#      tests_require=tests_require,
#      test_suite='nose.collector',
      include_package_data=True
    )
      
      
      
      
      
      