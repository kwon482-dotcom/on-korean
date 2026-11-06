# -*- coding: utf-8 -*-
"""
Phase 12: Topik2 (100 words)
"""
try:
    from scripts.data_p12_topik2_p1 import P12_TOPIK2_WORDS_P1
    from scripts.data_p12_topik2_p2 import P12_TOPIK2_WORDS_P2
except ImportError:
    from data_p12_topik2_p1 import P12_TOPIK2_WORDS_P1
    from data_p12_topik2_p2 import P12_TOPIK2_WORDS_P2

P12_TOPIK2_WORDS = P12_TOPIK2_WORDS_P1 + P12_TOPIK2_WORDS_P2
