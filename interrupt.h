#ifndef __INTERRUPT_H
#define __INTERRUPT_H

#define MASTER_ICW 0x20         /* マスターの初期化処理系 */
#define MASTER_OCW 0x21         /* マスターの操作処理系 */
#define SLAVE_ICW 0xA0          /* スレーブの初期化処理系 */
#define SLAVE_OCW 0xA1          /* スレーブの操作処理系 */
#define INT_BASE 0x20
#define INT_TIMER INT_BASE | 0x00 /* タイマ割り込み */
#define INT_KEYBD INT_BASE | 0x01 /* キーボード割り込み */
#define INT_MOUSE INT_BASE | 0x0c /* マウス割り込み */
#define IDT_NUM 256
#define i(n) void i##n();

/* 
 * /\* 割り込み処理関数の宣言 *\/
 * i(0)   i(1)   i(2)   i(3)   i(4)   i(5)   i(6)   i(7)   i(8)   i(9)
 * i(10)  i(11)  i(12)  i(13)  i(14)  i(15)  i(16)  i(17)  i(18)  i(19)
 * i(20)  i(21)  i(22)  i(23)  i(24)  i(25)  i(26)  i(27)  i(28)  i(29)
 * i(30)  i(31)  i(32)  i(33)  i(34)  i(35)  i(36)  i(37)  i(38)  i(39)
 * i(40)  i(41)  i(42)  i(43)  i(44)  i(45)  i(46)  i(47)  i(48)  i(49)
 * i(50)  i(51)  i(52)  i(53)  i(54)  i(55)  i(56)  i(57)  i(58)  i(59)
 * i(60)  i(61)  i(62)  i(63)  i(64)  i(65)  i(66)  i(67)  i(68)  i(69)
 * i(70)  i(71)  i(72)  i(73)  i(74)  i(75)  i(76)  i(77)  i(78)  i(79)
 * i(80)  i(81)  i(82)  i(83)  i(84)  i(85)  i(86)  i(87)  i(88)  i(89)
 * i(90)  i(91)  i(92)  i(93)  i(94)  i(95)  i(96)  i(97)  i(98)  i(99)
 * i(100) i(101) i(102) i(103) i(104) i(105) i(106) i(107) i(108) i(109)
 * i(110) i(111) i(112) i(113) i(114) i(115) i(116) i(117) i(118) i(119)
 * i(120) i(121) i(122) i(123) i(124) i(125) i(126) i(127) i(128) i(129)
 * i(130) i(131) i(132) i(133) i(134) i(135) i(136) i(137) i(138) i(139)
 * i(140) i(141) i(142) i(143) i(144) i(145) i(146) i(147) i(148) i(149)
 * i(150) i(151) i(152) i(153) i(154) i(155) i(156) i(157) i(158) i(159)
 * i(160) i(161) i(162) i(163) i(164) i(165) i(166) i(167) i(168) i(169)
 * i(170) i(171) i(172) i(173) i(174) i(175) i(176) i(177) i(178) i(179)
 * i(180) i(181) i(182) i(183) i(184) i(185) i(186) i(187) i(188) i(189)
 * i(190) i(191) i(192) i(193) i(194) i(195) i(196) i(197) i(198) i(199)
 * i(200) i(201) i(202) i(203) i(204) i(205) i(206) i(207) i(208) i(209)
 * i(210) i(211) i(212) i(213) i(214) i(215) i(216) i(217) i(218) i(219)
 * i(220) i(221) i(222) i(223) i(224) i(225) i(226) i(227) i(228) i(229)
 * i(230) i(231) i(232) i(233) i(234) i(235) i(236) i(237) i(238) i(239)
 * i(240) i(241) i(242) i(243) i(244) i(245) i(246) i(247) i(248) i(249)
 * i(250) i(251) i(252) i(253) i(254) i(255)
 * 
 * /\* 割り込みベクタテーブル *\/
 * void (*int_vector[IDT_NUM])() = {
 *   i0,   i1,   i2,   i3,   i4,   i5,   i6,   i7,   i8,   i9,
 *   i10,  i11,  i12,  i13,  i14,  i15,  i16,  i17,  i18,  i19,
 *   i20,  i21,  i22,  i23,  i24,  i25,  i26,  i27,  i28,  i29,
 *   i30,  i31,  i32,  i33,  i34,  i35,  i36,  i37,  i38,  i39,
 *   i40,  i41,  i42,  i43,  i44,  i45,  i46,  i47,  i48,  i49,
 *   i50,  i51,  i52,  i53,  i54,  i55,  i56,  i57,  i58,  i59,
 *   i60,  i61,  i62,  i63,  i64,  i65,  i66,  i67,  i68,  i69,
 *   i70,  i71,  i72,  i73,  i74,  i75,  i76,  i77,  i78,  i79,
 *   i80,  i81,  i82,  i83,  i84,  i85,  i86,  i87,  i88,  i89,
 *   i90,  i91,  i92,  i93,  i94,  i95,  i96,  i97,  i98,  i99,
 *   i100, i101, i102, i103, i104, i105, i106, i107, i108, i109,
 *   i110, i111, i112, i113, i114, i115, i116, i117, i118, i119,
 *   i120, i121, i122, i123, i124, i125, i126, i127, i128, i129,
 *   i130, i131, i132, i133, i134, i135, i136, i137, i138, i139,
 *   i140, i141, i142, i143, i144, i145, i146, i147, i148, i149,
 *   i150, i151, i152, i153, i154, i155, i156, i157, i158, i159,
 *   i160, i161, i162, i163, i164, i165, i166, i167, i168, i169,
 *   i170, i171, i172, i173, i174, i175, i176, i177, i178, i179,
 *   i180, i181, i182, i183, i184, i185, i186, i187, i188, i189,
 *   i190, i191, i192, i193, i194, i195, i196, i197, i198, i199,
 *   i200, i201, i202, i203, i204, i205, i206, i207, i208, i209,
 *   i210, i211, i212, i213, i214, i215, i216, i217, i218, i219,
 *   i220, i221, i222, i223, i224, i225, i226, i227, i228, i229,
 *   i230, i231, i232, i233, i234, i235, i236, i237, i238, i239,
 *   i240, i241, i242, i243, i244, i245, i246, i247, i248, i249,
 *   i250, i251, i252, i253, i254, i255
 * };
 */

#endif // __INTERRUPT_H
