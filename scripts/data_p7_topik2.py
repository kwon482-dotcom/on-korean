# -*- coding: utf-8 -*-
"""
Phase 7: TOPIK II (100 words)
"""

try:
    from scripts.data_p7_topik2_p1 import P7_TOPIK2_WORDS_P1
    from scripts.data_p7_topik2_p2 import P7_TOPIK2_WORDS_P2
except ImportError:
    from data_p7_topik2_p1 import P7_TOPIK2_WORDS_P1
    from data_p7_topik2_p2 import P7_TOPIK2_WORDS_P2

P7_TOPIK2_WORDS = P7_TOPIK2_WORDS_P1 + P7_TOPIK2_WORDS_P2
