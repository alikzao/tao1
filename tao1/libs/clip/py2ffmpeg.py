import json, cgi, os, sys, requests,  hashlib, time, tempfile, time, timeit
from pymongo import *

from urllib import *
import urllib

from datetime import datetime, timedelta
from libs.contents.contents import *
from core.core import *

# from core.lang import *


# avpath = ''
avpath = '/home/user/workspace/2/avconv/'
# avpath = '/home/user/workspace/1/avconv/'
cv = '.vob'
cv = '.avi'
pre_v = '.mp4'
pre_v = '.avi'
final_v = '.mp4'
final_v = '.avi'
iformat = '.png'
iformat = '.jpg'

bp = os.path.join(os.getcwd(), 'clip') #base_path


def screen_clip(doc_id, final):
	c = 'avconv -i {f_in} -an -ss 00:00:30 -r 1 -vframes 1 -y -f mjpeg {f_out}'.format(f_in = os.path.join(bp, doc_id, final),
	                                                                                   f_out = os.path.join(bp, doc_id, 'screen.jpg') )
	return c, cmd(c)

def cmd(c):
	print ('\n\n', '=' * 60, '\n\n', c, '\n\n')
	h = os.popen(c)
	lines = []
	for ln in iter(h.readline, ''):
		print (ln.rstrip())
		lines.append(ln.rstrip())
	return '\n'.join(lines)


def time2sec(tm):
	return int(tm[0:2]) * 3600 + int(tm[3:5]) * 60 + int(tm[6:8])

def sec2time(s):
	return str(s/3600 % 60).zfill(2)+':'+str(s/60 % 60).zfill(2)+':'+str(s % 60).zfill(2)



def cut_frag_v(doc_id, frag, f_start, f_len, ext):
	""" Разрезание длинного файла на фрагменты а потом фрагменты на картинки каждый"""
	os.mkdir(os.path.join(bp, doc_id, 'out_v', str(frag)))
	cmd('avconv -i {f_in} -ss {start} -t {len} -q 1 -s hd720 -threads 8 -r 25 -y {f_out}'.format(
		f_in = os.path.join(bp, doc_id, 'in_v', str(frag)+'.'+ext),
		f_out = os.path.join(bp, doc_id, 'in_v', str(frag)+'_tmp.avi'),
		start = f_start, len = f_len
	))
	cmd('avconv -i {f_in} -q 1 -s hd720 -threads 8 -y {f_out}'.format(
		f_in = os.path.join(bp, doc_id, 'in_v', str(frag)+'_tmp.avi'),
		f_out = os.path.join(bp, doc_id, 'out_v', str(frag), '%08d'+iformat)
	))


def cut_frag_a(doc_id, frag, f_start, f_len, track, vol, ext):
	""" вырезание из видео дорожки аудио файла    конвертация видео файла в аудио"""
	cmd('avconv -i {f_in} -ss {start} -t {len} -vol {vol} -vn -f u16le -ac 2 -ar 44100 -threads 8 -y {f_out}'.format(
		f_in = os.path.join(bp, doc_id, 'in_'+track, str(frag)+'.'+ext),
		f_out = os.path.join(bp, doc_id, 'out_'+track, str(frag)+'.a'),
		start = f_start, len = f_len, vol = vol
	))


def clone_mp3(doc_id, frag, flen, track):
	""" Тиражирование пустого звука """
	anull = get_settings('lib_path')+'/system/silence.a'
	anull = (' '.join([anull for i in range( time2sec(flen) ) ]))
	cmd ('cat {anull} > {f_out}'.format(anull = anull, f_out = os.path.join(bp, doc_id, 'out_'+track, str(frag)+'.a')))


def clone_img(doc_id, frag, ext, tm):
	""" клонирование картинок в нужном количестве """
	path = os.path.join(bp, 'out_v', str(frag))
	os.mkdir(path)
	mod = 0o777
	os.chmod(path, mod)
	cmd('avconv -loop 1 -i {f_in} -t {len} -q 1 -s hd720 -threads 8 -y {f_out}'.format(
		f_in = os.path.join(bp, doc_id, 'in_v', str(frag)+'.'+ext),
		f_out = os.path.join(bp, doc_id, 'out_v', str(frag), '%08d', iformat),
		len = tm
	))


def join_frag_a(doc_id, track, lst):
	tracks = []
	for f in lst:
		tracks.append(os.path.join(bp, doc_id, 'out_{}'.format(track), str(f)+'.a'))
	fin = format(' '.join(tracks))
	cmd('cat {fin} > {f_out}'.format( fin = fin, f_out = os.path.join(bp, doc_id, 'out_'+track+'.a') ))
	cmd('avconv -q 1 -f u16le -ac 2 -ar 44100 -threads 8 -i {f_in} -y {f_out}'.format(
		f_in = os.path.join(bp, doc_id, 'out_'+track+'.a'),
		f_out = os.path.join(bp, doc_id, 'out_'+track+'.wav'),
	))


def join_frag_v(doc_id, lst):
	""" Склеивание из фрагментов дорожки """
	ctr = 0
	for d in lst:
		frag_p = os.path.join(bp, doc_id, 'out_v', str(d))
		for f in sorted([ ff for ff in os.listdir(frag_p) if os.path.isfile( os.path.join(frag_p, ff) ) ]):
			ctr += 1
			print (f)
			os.rename(os.path.join(frag_p, f), os.path.join(bp, doc_id, 'out_v', '{c:08d}{i}'.format(c=ctr, i=iformat)))
	cmd('avconv -i {f_in} -q 1 -s hd720 -threads 8 -y {f_out}'.format(
		f_in = os.path.join(bp, doc_id, 'out_v', '%08d'+iformat),
		f_out = os.path.join(bp, doc_id, 'out_v.avi')
	))


def join_av_track(doc_id):
	""" склеивание аудио и видео дорожек """
	cmd('sox -m {f_in1} {f_in2} {f_out}'.format(
		f_in1 = os.path.join(bp, doc_id, 'out_a.wav'),
		f_in2 = os.path.join(bp, doc_id, 'out_v.wav'),
		f_out = os.path.join(bp, doc_id, 'out.wav'),
	))
	cmd('avconv -i {f_in1} -i {f_in2} -c:v copy -s hd720 {f_out}'.format(
		f_in1 = os.path.join(bp, doc_id, 'out.wav'),
		f_in2 = os.path.join(bp, doc_id, 'out_v.avi'),
		f_out = os.path.join(bp, doc_id, 'final.avi'),
	))


def cut_files(f_in, f_out, f_start, f_len, volume = 1024, del_video = False):
	m1 = ''; m2 = ''
	m2 += '-vol ' + str(volume)
	if del_video: m2 += ' -map 0:a'
	cmd('avconv {m1} -i {f_in} -ss {start} -t {len} {m2} -strict experimental -q 1 -b:a 128k -preset libvpx-720p -s hd720 -threads 8 -y {f_out}'
	    .format(start = f_start, len = f_len, f_in = f_in, f_out = f_out, m1 = m1, m2 = m2, bp=bp))


def conv_img_to_files(doc_id, f_in, f_out, tm):
	anull = get_settings('lib_path')+'/system/123.mp3'
	cmd ('avconv -loop 1 -i {f_in} -t {tm} -y {f_out}'.format(
		f_out = os.path.join(bp, doc_id, 'v.mkv'),
		f_in = f_in, tm = tm
	))
	cmd ('avconv -i {f_in} -y {f_out}'.format(
		f_in = os.path.join(bp, doc_id, 'v.mkv'),
		f_out = os.path.join(bp, doc_id, 'v.avi')
	))

	anull = 'concat:'+('|'.join([anull for i in range( time2sec(tm) ) ]))
	cmd ('avconv -i "{anull}" -y {f_out}'.format(f_out = os.path.join(bp, doc_id, 'a.avi'), anull = anull))
	cmd ('avconv -i {a} -i {v} -map 0:a -map 1:v -y {f_out}'.format(
		a = os.path.join(bp, doc_id, 'a.avi'),
		v = os.path.join(bp, doc_id, 'v.avi'),
		f_out = f_out
	))


def glue_files(f_in, f_out):
	files = '|'.join([f for f in f_in])
	cmd ('avconv -i "concat:{f_in}" -q 1 -b:a 128k -preset libvpx-720p -s hd720 -threads 8 -y {f_out}'.format(f_in = files, f_out = f_out))


def join_files(f_in1, f_in2, f_out):
	cmd ('avconv -i {f_in1} -i {f_in2} -filter_complex amix=inputs=2 -q 1 -b:a 128k -preset libvpx-720p -s hd720 -threads 2 -y {f_out}'
	     .format(f_in1 = f_in1, f_in2 = f_in2, f_out = f_out))


def conv_video(doc_id):
	cmd ('avconv -i {f_in} -threads 8 -q 1 -s hd720 -y {f_out}'.format(
		f_in = os.path.join(bp, doc_id, 'final.avi'),
		f_out = os.path.join(bp, doc_id, 'final.flv')
	))
	return 'final.flv'


