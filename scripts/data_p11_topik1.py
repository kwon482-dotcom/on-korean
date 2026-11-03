# -*- coding: utf-8 -*-
"""
Phase 11: Topik1 (100 words)
"""
try:
    from scripts.data_p11_topik1_p1 import P11_TOPIK1_WORDS_P1
    from scripts.data_p11_topik1_p2 import P11_TOPIK1_WORDS_P2
except ImportError:
    from data_p11_topik1_p1 import P11_TOPIK1_WORDS_P1
    from data_p11_topik1_p2 import P11_TOPIK1_WORDS_P2

P11_TOPIK1_WORDS = P11_TOPIK1_WORDS_P1 + P11_TOPIK1_WORDS_P2
