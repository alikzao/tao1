import os, time
import re
import datetime
import hashlib
from uuid import uuid4

from pymongo import *
from aiohttp import web, HttpMessage
from aiohttp_session import get_session

import settings


def die(mess):
    raise Exception(str(mess))


def get_settings(name, def_val=None):
    if name in settings.__dict__: return settings.__dict__[name]
    else: return def_val


def locale_date(format, dt, loc = 'en_US.UTF-8'):
    """ dt - set """
    import locale
    lc = locale.getdefaultlocale()
    # lc = locale.getlocale(locale.LC_ALL)
    locale.setlocale(locale.LC_ALL, loc)
    res = time.strftime(format, dt)
    locale.setlocale(locale.LC_ALL, lc)
    return res


def format_date(_dt, format = '%Y-%m-%d'):
    try:
        dt = datetime.strptime(_dt, '%Y-%m-%d')
        return dt.strftime(format).decode('UTF-8')
    except:
        return _dt


def get_const_value(request, const_name, def_val=None):
    res = request.db.doc.find_one({'doc_type':'des:conf', "doc.name": const_name})
    if not res:
        res = {'_id': uuid4().hex, 'doc_type':'des:conf', 'doc': { 'name': const_name, 'value': def_val, 'title': const_name }}
        request.db.doc.save(res)
    return res['doc']['value']


def set_const_value(request, const_name, val):
    db = request.db
    res = db.doc.find_one({'doc_type':'des:conf', "doc.name": const_name})
    if not res:
        res = {'_id': uuid4().hex, 'doc_type':'des:conf', 'doc': { 'name': const_name, 'value': val, 'title': const_name }}
    else:
        res['doc']['value'] = val
    db.doc.save(res)
    return res['doc']['value']


# def ct(sub, lang = None):
#     return translate(lang, sub)

def cur_lang(request):
    # s = yield from get_session(request)
    s = get_from(get_session(request))
    if s.__dict__.get('lang') is None:
        s['lang'] = get_settings('lang', 'en')
    return s['lang']


def get_from(coro):
    try:
        while True: next(coro)
    except StopIteration as e:
        return e.value
    except:
        raise


def get_post(request):
    data = get_from( request.post() )
    return data


def ct(request, sub, lang = None):
    if not lang:
        lang = cur_lang(request)
    return translate(lang, sub)


def translate(lang, subject):
    if not subject: return ''
    if isinstance(subject, int):
        return subject
    if isinstance(subject, float):
        return subject
    if isinstance(subject, str):
        return subject
    if isinstance(subject, (list, tuple)):
        subject = dict(subject)
        print('subject', subject)
    # print( "=======", type(subject))
    assert isinstance(subject, dict)
    return subject.get(lang, '-')


def session(request):
    return get_from(get_session(request))


def get_current_user(request, full=False):
    s = session( request )
    if not 'user_id' in s or s['user_id'] == 0 or s['user_id'] == 'guest':
        s['user_id'] = 'guest'
    return 'user:'+s['user_id'] if full else s['user_id']


def get_admin(request, full=False):
    from libs.contents.contents import get_doc
    name = 'user:'+(get_settings('admin') or get_domain() )
    if full: return get_doc(request, name)
    return name


def user_not_logged():
    return web.HTTPSeeOther('/login')


def get_domain():
    """get domain, parse, get database name """
    domen = re.split('\\.', get_host())
    db_name = domen[1 if domen[0] == 'www' else 0]
    return db_name


def get_host(request):
    host = settings.domain if request.environ['HTTP_HOST'] == 'localhost' else request.environ['HTTP_HOST']
    return host


def getmd5(word, count=1):
    """ get md5 hash"""
    for x in range(count):
        a = hashlib.md5()
        a.update(word.encode('utf-8'))
        word = a.hexdigest()
    return word


def htmlspecialchars(text):
    if text is None: return None
    return text.replace("&", "&amp;").replace('"', "&quot;").replace("<", "&lt;").replace(">", "&gt;")


def create_date():
    return time.strftime("%Y-%m-%d %H:%M:%S")


def sub(request, user, link, subject): #TODO  do not expect the system to send all letters.
    admin = get_admin(True)
    mail = admin['doc']['mail'] if 'mail' in admin['doc'] else ''
    if not mail:  return {"result":"ok"}
    db = request.db
    from libs.contents.contents import get_doc
    doc = get_doc(user)
    db.queue.mail.save({"_id": uuid4().hex, "subject":subject, "to":admin['doc']['mail'], 'body': link})
    users = doc['friends'] if doc and 'friends' in doc else {}
    for res in users:
        friend = get_doc(res)
        if friend['doc']['sub'] == 'true' :
            db.queue.mail.save({"_id": uuid4().hex, "subject":subject, "to":friend['doc']['mail'], 'body': link})
    return {"result":"ok"}


def mail(request, email, head, text):
    doc = {"_id": uuid4().hex, "subject":head, "to":email, 'body': text}
    request.db.queue.mail.save(doc)


def route_mail(request, to, subject, text): #TODO  do not expect the system to send all letters.
    """ save letter  route_mail(request, mail, 'Confirmation of registration ' + dom, text)
	"""
    request.db.queue.mail.save({"_id": uuid4().hex, "subject":subject, "to":to, 'body': text})


def s_mail(to, from_, mess):
    import smtplib
    from email.mime.text import MIMEText
    s = smtplib.SMTP()
    s.connect('localhost') # connect to the SMTP server
    msg = MIMEText('', _charset='utf-8')
    msg['Subject'] = mess
    msg['From'] = from_
    msg['To'] = to
    s.sendmail(msg['From'], [msg['To']], msg.as_string())
    s.quit()


def send_mail(app):
    import smtplib
    from email.mime.text import MIMEText
    s = smtplib.SMTP()
    s.connect('localhost') # connect to the SMTP server
    while True:
        doc = app.db.queue.mail.find_one({"sending":{"$exists":False}})
        if not doc: break
        doc['sending']= True
        app.db.queue.mail.save(doc)
        to = doc['to']
        subject = doc['subject']
        msg = MIMEText( doc['body'].encode('UTF-8'), _subtype='html', _charset='utf-8' )
        msg['Subject'] = subject
        msg['From'] = get_const_value(app, 'sub_mail', 'mailer@'+settings.domain)
        msg['To'] = to
        print('send_msg', msg)
        s.sendmail(msg['From'], [msg['To']], msg.as_string())
        app.db.queue.mail.remove(doc)
    s.quit()


month_names = [u'Январь', u'Февраль', u'Март', u'Апрель', u'Май', u'Июнь', u'Июль', u'Август', u'Сентябрь', u'Октябрь', u'Ноябрь', u'Декабрь']
day_names = [u'Понедельник', u'Вторник', u'Среда', u'Четверг', u'Пятница', u'Суббота', u'Воскресенье']
day_names_short = [u'Пн', u'Вт', u'Ср', u'Чт', u'Пт', u'Сб', u'Вс']

def calendar(date_range=None):
    import calendar
    if not date_range:
        dt = datetime.today().timetuple()
        year = dt[0]
        month = dt[1]
    else:
        year = int(date_range[:4])
        if len(date_range) > 4: month = int(date_range[5:7])
        else: month = 1
    month_name = month_names[month - 1]
    c = calendar.Calendar()
    rows = []; row = []
    for d in c.itermonthdates(year, month):
        w = d.weekday()
        day = d.strftime('%Y-%m-%d')
        row.append((day, d.timetuple()[1] == month))
        if w == 6: #Sunday
            rows.append(row)
            row = []
    return year, month, month_name, rows


def redirect(request, url='/', code=None):
    if code is None:
        return web.HTTPSeeOther(url)
    elif code == 200:
        return web.HTTPOk(url)
    elif code == 302:
        raise web.HTTPFound(url)
    elif code == 404:
        return web.HTTPFound( url )


def get_hash(number=4):
    return uuid4().hex[:number]


def no_script(text, light=False):
    if light:
        text = re.sub(r"(position:[\s]*absolute;)", '', text)
        text = re.sub(r"on[a-z-A-Z:]+\s*=\s*'[^']*'", '', text)
        text = re.sub(r'on[a-z-A-Z:]+\s*=\s*"[^"]*"', '', text)
        text = re.sub(r'</?lj[^>]*>', '', text)
        text = re.sub(r'</?style[^>]*>', '', text)
        text = re.sub(r'</?script[^>]*>', '', text)
    else:
        text = re.sub(r'style\s*=\s*"[^"]*"', '', text)
        text = re.sub(r"on[a-z-A-Z:]+\s*=\s*'[^']*'", '', text)
        text = re.sub(r'on[a-z-A-Z:]+\s*=\s*"[^"]*"', '', text)
        text = re.sub(r'style\s*=\s*\'[^\']*\'', '', text)
        text = re.sub(r'</?lj[^>]*>', '', text)
        text = re.sub(r'</?style[^>]*>', '', text)
        text = re.sub(r'</?script[^>]*>', '', text)
    return text

