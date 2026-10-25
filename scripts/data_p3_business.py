# -*- coding: utf-8 -*-
"""Phase 3 - 비즈니스 & 시사 고급 한국어 120단어 (100% 고유 검증 완료)"""

import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from data_p3_business_part1 import P3_BUSINESS_WORDS_PART1
from data_p3_business_part2 import P3_BUSINESS_WORDS_PART2

P3_BUSINESS_WORDS = P3_BUSINESS_WORDS_PART1 + P3_BUSINESS_WORDS_PART2
