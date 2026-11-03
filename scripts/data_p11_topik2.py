# -*- coding: utf-8 -*-
"""
Phase 11: Topik2 (100 words)
"""
try:
    from scripts.data_p11_topik2_p1 import P11_TOPIK2_WORDS_P1
    from scripts.data_p11_topik2_p2 import P11_TOPIK2_WORDS_P2
except ImportError:
    from data_p11_topik2_p1 import P11_TOPIK2_WORDS_P1
    from data_p11_topik2_p2 import P11_TOPIK2_WORDS_P2

P11_TOPIK2_WORDS = P11_TOPIK2_WORDS_P1 + P11_TOPIK2_WORDS_P2
