#!/usr/bin/env python
# coding: utf-8

#python manage.py startapp People
#python manage.py syncdb
#python manage.py runserver
#python django-admin.py startproject iFriends
#python manage.py validate

# 1-й путь к сайту типа '/sites/bezholopov' 2-й для копилирования cpl
# python lang.py /sites/formemob cpl
import sys, getopt, os, time
from shutil import *
import re
#from settings import *
#from core.dao_core import vd


#def vd(*mess):
#	logee(mess)

#from logbook import Logger, FileHandler
#def logee(mess):
#	file = FileHandler('app.log')
#	loge = Logger('	Logbook')
#	#	t = str(mess)#	if t == str or t == unicode or t == int or t == float: str(mess)#	else: mess = json.dumps(mess)
#	with file.applicationbound():
#		loge.info(str(mess))



list_lang = ['ru_RU', 'en_US']
s = str(sys.argv)
s = s[1:-1]; app = []
for word in s.split(", "):
	app.append(word)
lib_path = '/home/user/workspace/py.mongo'
#templ_dir = lib_path+'/core/templ'
#destination_dir = str(os.getcwd()) 

#input_f = app[1]
#out_f = app[2] 
#sel_lang = app[3] 

def iter_po(dir, is_list=True):
	""" Идем по компонентам ищем там локаль и превращаем файлик с переводами в бинарник."""
	#	msgfmt -o locale/ru/LC_MESSAGES/myapp.mo myapp-ru.po
	if is_list: #тут бежим не по компонентам
		for component in os.listdir(dir):
			path_ = os.path.join(dir, component, 'locale')
			if os.path.isdir(path_):
				for res in os.listdir(path_):
					path = os.path.join(path_, res, 'LC_MESSAGES')
					print (path)
					if os.path.isdir(path):
						po_f = os.path.join(path, '_.po')
						mo_f = os.path.join(path, '_.mo')
						os.popen("msgfmt -o %s %s" % (mo_f, po_f )).read()
	else: # тут идем по переводам из проекта.
		path_ = os.path.join(dir, 'locale')
		if os.path.isdir(path_):
			for res in os.listdir(path_):
				path = os.path.join(path_, res, 'LC_MESSAGES')
				print (path)
				if os.path.isdir(path):
					po_f = os.path.join(path, '_.po')
					mo_f = os.path.join(path, '_.mo')
					os.popen("msgfmt -o %s %s" % (mo_f, po_f )).read()

def iter_comp(dir, is_list=True):
	""" Идем по шаблонам """
	if is_list:
		for component in os.listdir(dir):
			path = os.path.join(dir, component, 'templ')
			if os.path.isdir(path):
				iter_templ(path)
	else:
		path = os.path.join(dir, 'templ')
		if os.path.isdir(path):
			iter_templ(path)


aaa = """# SOME DESCRIPTIVE TITLE.
# Copyright (C) YEAR THE PACKAGE'S COPYRIGHT HOLDER
# This file is distributed under the same license as the PACKAGE package.
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\\n"
"Report-Msgid-Bugs-To: \\n"
"POT-Creation-Date: %s\\n"
"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n"
"Language-Team: LANGUAGE <LL@li.org>\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"

""" % (time.strftime("%Y-%m-%d %H:%M%z"))
def iter_templ(dir):
	""" Из шаблонов извлекаем строчки для переводов и закидуем их в pot файлы.
	А затем создаем по списку языков необходимые _.po файлы или сливаем с уже существующими.
	"""
	# (py -> pot) xgettext myapplib/*.py -o myapp.pot	
	out_f = os.path.join(dir, '..', 'locale', '_.pot')
	file_o = open(out_f, 'w')
	# Записываем в файл заголовок.
	file_o.write(aaa)
	print (out_f)
	for name in os.listdir(dir):
		if name.endswith('.tpl'):
			load_translation(os.path.join(dir, name), file_o)
	file_o.close()
#	os.popen("xgettext %s -o %s" % (tmp, out_f )).read()
	for res in list_lang:
		lang = res[:2]
		po_path = os.path.join(dir, '..', 'locale', lang)
		if not os.path.isdir(po_path): os.makedirs(po_path, 0o755)
		po_path = os.path.join(po_path, 'LC_MESSAGES')
		if not os.path.isdir(po_path): os.makedirs(po_path, 0o755) #os.makedirs(path, mode=0o777, exist_ok=False) 0755
		po_f = os.path.join(po_path, '_.po')
		if not os.path.isfile(po_f): 
			# (pot -> po) msginit -l ru -i myapp.pot -o myapp-ru.po -l ru_RU.UTF-8
			os.popen("msginit --no-translator -i %s -o %s -l %s" % ( out_f, po_f, res+'.UTF-8')).read()
		else: # 'msgmerge myapp-ru.po myapp.pot -o new.po'
			os.popen("msgmerge %s %s -o %s" % (po_f, out_f, po_f)).read()
#	os.remove(tmp)
			
def load_translation(in_f, file):
	""" Извлекаем строки из шаблона и записуем их в файл. """
#	vd( in_f)
	with open(in_f, 'r') as f: l = f.read().split('\n')
	n = 0; r = {}
	for rs in l:
		n += 1
		# находим подчеркивание со скобочками
		aa = re.findall(r'_\([^)]+\)', rs)
		for res in aa:
			# вырезаем саму строчку без подчеркивания скобок и кавычек
			res = res[3:-2]
			# смотрим нет ли еще такой строчки
			if not res in r: r[res] = []
			# Добавляем номер строки
			r[res].append(n)
	for res, nums in r.iteritems():
		file.write('#: '+in_f+':'+','.join([str(x) for x in nums])+'\n')
		file.write('msgid "'+res+'"\n')
		file.write('msgstr ""\n\n')

app_path = lib_path+app[1][1:-1]
# теперь если у нас стоит аргумент в 'cpl' то компилируем если нет то просто собираем строчки.
if len(app) > 2 and app[2][1:-1] == 'cpl':
	iter_po(lib_path + '/', False)
	iter_po(lib_path +'/app/')
	iter_po(app_path +'/app/')
	iter_po(app_path + '/', False)
else:
	iter_comp(lib_path + '/', False)
	iter_comp(lib_path +'/app/')
	iter_comp(app_path +'/app/')
	iter_comp(app_path + '/', False)

		


























