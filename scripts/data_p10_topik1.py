# -*- coding: utf-8 -*-
"""
Phase 10: Topik1 (200 words)
"""
try:
    from scripts.data_p10_topik1_p1 import P10_TOPIK1_WORDS_P1
    from scripts.data_p10_topik1_p2 import P10_TOPIK1_WORDS_P2
    from scripts.data_p10_topik1_p3 import P10_TOPIK1_WORDS_P3
    from scripts.data_p10_topik1_p4 import P10_TOPIK1_WORDS_P4
except ImportError:
    from data_p10_topik1_p1 import P10_TOPIK1_WORDS_P1
    from data_p10_topik1_p2 import P10_TOPIK1_WORDS_P2
    from data_p10_topik1_p3 import P10_TOPIK1_WORDS_P3
    from data_p10_topik1_p4 import P10_TOPIK1_WORDS_P4

P10_TOPIK1_WORDS = P10_TOPIK1_WORDS_P1 + P10_TOPIK1_WORDS_P2 + P10_TOPIK1_WORDS_P3 + P10_TOPIK1_WORDS_P4
