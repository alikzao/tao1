#!/usr/bin/env python

import os, sys, time, argparse, shutil

def manage_console():
    parser = argparse.ArgumentParser()

    parser.add_argument('-project', '-startproject', '-p', type=str, help='Create project' )
    parser.add_argument('-app', '-startapp', '-a',         type=str, help='Create app'     )
    args = parser.parse_args()

    print( 'args.project', args.project)

    p_root = os.path.dirname(__file__)

    if '/core' in p_root:
        p_root = p_root[:-5]
    else:
        __import__('tao1')
        module = sys.modules['tao1']
        p_root = os.path.dirname( os.path.abspath(module.__file__) )

    if args.project is not None:
        shutil.copytree(  os.path.join( p_root , 'sites', 'daoerp'), os.path.join( str(args.project) ) )
        set_file = """
import os

session_key = b'Thirty  two  length  bytes  key.'

debug = True

root_path = os.path.dirname(__file__)
tao_path  = '%s'

database={"login":"admin", "pass":"passwd", "host":["127.0.0.1:27017"], 'name':'test'}
        """ % p_root
        with open(os.path.join( str(args.project) , 'settings.py'), 'w') as f: f.write(set_file)
        # os.symlink(source, link_name, target_is_directory=False, *, dir_fd=None)
        dir = os.path.join ( p_root, 'libs' )
        # r_p = os.path.join ( os.path.dirname(__file__), 'apps' )
        for name in os.listdir( dir ):
            if name == '__pycache__' or name == '__init__.py': continue
            os.symlink(
                os.path.join( dir, name, 'static' ),
                os.path.join( os.getcwd(), args.project, 'static', name)
            )

        r_p = os.path.join( os.getcwd(), args.project, 'apps')
        for name in os.listdir( r_p ):
            if name == '__pycache__' or name == '__init__.py': continue
            os.symlink(
                os.path.join(r_p, name, 'static' ),
                os.path.join( os.getcwd(), args.project, 'static', name)
            )

    elif args.app is not None:
        name = str(args.app)
        shutil.copytree(
            os.path.join( p_root, 'sites', 'daoerp', 'apps', 'app'),
            os.path.join( name )
        )

        root_path = os.getcwd()[:-4]
        os.symlink(
            os.path.join( root_path, 'apps', name, 'static'),
            os.path.join( root_path, 'static', name )
        )

    print( args )

# if __name__ == "__main__":
#     manage_console()




# db.doc.save({"_id", "123", "Update", [{"_id", '1', "time":'345', "Version", '3'}, {"_id", '2', "time":'234', "Version", '4'}]})











