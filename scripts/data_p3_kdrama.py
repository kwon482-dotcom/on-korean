# -*- coding: utf-8 -*-
"""Phase 3 - K-드라마 & 실전 리얼 회화 120단어 (100% 고유 검증 완료)"""

import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from data_p3_kdrama_part1 import P3_KDRAMA_WORDS_PART1
from data_p3_kdrama_part2 import P3_KDRAMA_WORDS_PART2

P3_KDRAMA_WORDS = P3_KDRAMA_WORDS_PART1 + P3_KDRAMA_WORDS_PART2
