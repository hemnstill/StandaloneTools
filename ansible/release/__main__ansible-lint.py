# -*- coding: utf-8 -*-
import re
import sys
from ansiblelint.__main__ import _run_cli_entrypoint
if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(_run_cli_entrypoint())
