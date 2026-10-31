# -*- coding: utf-8 -*-
"""
Phase 8: TOPIK I (100 words)
"""

try:
    from scripts.data_p8_topik1_p1 import P8_TOPIK1_WORDS_P1
    from scripts.data_p8_topik1_p2 import P8_TOPIK1_WORDS_P2
except ImportError:
    from data_p8_topik1_p1 import P8_TOPIK1_WORDS_P1
    from data_p8_topik1_p2 import P8_TOPIK1_WORDS_P2

P8_TOPIK1_WORDS = P8_TOPIK1_WORDS_P1 + P8_TOPIK1_WORDS_P2
