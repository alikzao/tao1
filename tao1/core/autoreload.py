import os, sys
import asyncio
import pyinotify
import importlib
import settings
import time
root_path = settings.root_path
tao_path  = settings.tao_path

class MyEventHandler(pyinotify.ProcessEvent):
    # def process_IN_ACCESS(self, event):
    #     print ("ACCESS event:", event.pathname)

    # def process_IN_ATTRIB(self, event):
    #     print ("ATTRIB event:", event.pathname)

    # def process_IN_CLOSE_NOWRITE(self, event):
    #      print ("CLOSE_NOWRITE event:", event.pathname)

    # def process_IN_CLOSE_WRITE(self, event):
    #     print ("CLOSE_WRITE event:", event.pathname)

    # def process_IN_CREATE(self, event):
    #     print ("CREATE event:", event.pathname)

    # def process_IN_DELETE(self, event):
    #     print ("DELETE event:", event.pathname)

    def process_IN_MODIFY(self, event):
        print ("MODIFY event:", event)
        print ("MODIFY event:.pathname", event.pathname)
        pathname  = event.pathname
        name  = event.name

        # time.sleep(1)  # delays for 5 seconds
        print('name1', name)
        if 'jb_tmp' in name:
            name = name[:-10]
            pathname = pathname[:-10]
        if name.endswith('.py'):
            print('name2', name)

            for module in sys.modules.values():
                if hasattr(module, '__file__'):
                    if module.__file__ == pathname:
                        print('module->', module.__file__)
                        importlib.reload( module )

class EventHandler(pyinotify.ProcessEvent):
    def my_init(self, loop=None):
        self.loop = loop if loop else asyncio.get_event_loop()


    def process_IN_MODIFY(self, event):
        print("MODIFY event:.pathname", event.pathname)
        pathname = event.pathname
        name = event.name

        # time.sleep(1)  # delays for 5 seconds
        print('name1', name)
        if 'jb_tmp' in name:
            name = name[:-12]
            pathname = pathname[:-12]
        print('name2', name)
        if name.endswith('.py'):
            for module in sys.modules.values():
                if hasattr(module, '__file__'):
                    if module.__file__ == pathname:
                        print('module->', module.__file__, module)
                        importlib.import_module('libs.sites')
                        importlib.reload(module)


# if __name__ == '__main__':
def inotify_start(loop):
    print('inotify start . . .')
    # watch manager
    wm = pyinotify.WatchManager()
    mask = pyinotify.IN_MODIFY  # watched events

    wm.add_watch(root_path, pyinotify.ALL_EVENTS, rec=True)
    wm.add_watch(tao_path,  pyinotify.ALL_EVENTS, rec=True)

    # handler = EventHandler(file=filename, loop=loop)
    handler = EventHandler( loop=loop )
    notifier = pyinotify.AsyncioNotifier(wm, loop, default_proc_fun=handler)







