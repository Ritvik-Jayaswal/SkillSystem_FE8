.thumb
.equ QuickcastID, SkillTester+4
.equ GetWeaponType, 0x8017549 @returns weapon type for item ID in r0

push {r4-r7, lr}

@check if we are the attacker
ldr r5,=0x203a4ec @attacker battle struct address
cmp r0,r5
bne GoBack
mov r4, r0 @r4 = attacker battle struct
mov r5, r1 @r5 = defender battle struct

@check if unit has Quickcast skill
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @attacker data
ldr r1, QuickcastID
.short 0xf800
cmp r0, #0
beq GoBack

@check if attacking from range 1
ldr r0,=0x203A4D4 @gBattleStats address
ldrb r0,[r0,#0x2] @range is at offset 0x2
cmp r0,#1
bne GoBack @if not range 1, exit

@check if using a magic tome (Anima=5, Light=6, Dark=7)
mov r0,#0x4A @weapon item short offset in battle struct
ldrh r0,[r4,r0] @get equipped weapon item
ldr r1,=GetWeaponType
mov lr,r1
.short 0xf800 @call GetWeaponType
@r0 now contains weapon type

cmp r0,#5 @Anima
beq ApplyBrave
cmp r0,#6 @Light
beq ApplyBrave
cmp r0,#7 @Dark
beq ApplyBrave
b GoBack @not a magic tome, exit

ApplyBrave:
@set the brave flag on our weapon
mov r0,r4
add r0,#0x4C @item ability word
ldr r1,[r0]
mov r2,#0x20 @brave flag
orr r1,r2
str r1,[r0]

GoBack:
pop {r4-r7}
pop {r0}
bx r0

.ltorg
.align

SkillTester:
@POIN SkillTester
@WORD QuickcastID
