# -*- coding: utf-8 -*-
"""
Phase 10: Topik2 (200 words)
"""
try:
    from scripts.data_p10_topik2_p1 import P10_TOPIK2_WORDS_P1
    from scripts.data_p10_topik2_p2 import P10_TOPIK2_WORDS_P2
    from scripts.data_p10_topik2_p3 import P10_TOPIK2_WORDS_P3
    from scripts.data_p10_topik2_p4 import P10_TOPIK2_WORDS_P4
except ImportError:
    from data_p10_topik2_p1 import P10_TOPIK2_WORDS_P1
    from data_p10_topik2_p2 import P10_TOPIK2_WORDS_P2
    from data_p10_topik2_p3 import P10_TOPIK2_WORDS_P3
    from data_p10_topik2_p4 import P10_TOPIK2_WORDS_P4

P10_TOPIK2_WORDS = P10_TOPIK2_WORDS_P1 + P10_TOPIK2_WORDS_P2 + P10_TOPIK2_WORDS_P3 + P10_TOPIK2_WORDS_P4
