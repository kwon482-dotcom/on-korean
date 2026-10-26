# -*- coding: utf-8 -*-
"""Phase 4 - K-드라마 & 실전 리얼 회화 Combined (100단어)"""

import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from data_p4_kdrama_part1 import P4_KDRAMA_WORDS_PART1
from data_p4_kdrama_part2 import P4_KDRAMA_WORDS_PART2

P4_KDRAMA_WORDS = P4_KDRAMA_WORDS_PART1 + P4_KDRAMA_WORDS_PART2
