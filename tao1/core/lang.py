
# 1-й путь к сайту типа '/sites/site' 2-й для копилирования cpl
# python lang.py /sites/site cpl
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
#	#	t = str(mess)#	if t == str or t == str or t == int or t == float: str(mess)#	else: mess = json.dumps(mess)
#	with file.applicationbound():
#		loge.info(str(mess))



list_lang = ['ru_RU', 'en_US']
s = str(sys.argv)
s = s[1:-1]; app = []
for word in s.split(", "):
	app.append(word)
lib_path = '/home/'
#templ_dir = lib_path+'/core/templ'
#destination_dir = str(os.getcwd()) 

#input_f = app[1]
#out_f = app[2] 
#sel_lang = app[3] 

def iter_po(dir, is_list=True):
	""" Come on components, looking for where the locale and convert a file with translations in binary file."""
	#	msgfmt -o locale/ru/LC_MESSAGES/myapp.mo myapp-ru.po
	if is_list: #then run not by component
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
	else: # then go on transfers from the project.
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
	""" Come on templates """
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
	""" From template to extract the line transfers and we put them in a pot files.
And then create the list of languages necessary _.po files or merge with existing ones.
	"""
	# (py -> pot) xgettext myapplib/*.py -o myapp.pot	
	out_f = os.path.join(dir, '..', 'locale', '_.pot')
	file_o = open(out_f, 'w')
	# Write in the header file.
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
	""" Extract lines from a template and save it to a file. """
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
			# Add line number
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

		


























