# -*- coding: utf-8 -*-
import re
import sys
import os

_current_script_path: str = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(_current_script_path, 'Lib', 'site-packages'))

from poetry.console.application import main
if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(main())
