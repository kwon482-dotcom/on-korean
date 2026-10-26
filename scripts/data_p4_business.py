# -*- coding: utf-8 -*-
"""Phase 4 - 비즈니스 & 시사 고급 한국어 Combined (100단어)"""

import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from data_p4_business_part1 import P4_BUSINESS_WORDS_PART1
from data_p4_business_part2 import P4_BUSINESS_WORDS_PART2

P4_BUSINESS_WORDS = P4_BUSINESS_WORDS_PART1 + P4_BUSINESS_WORDS_PART2
