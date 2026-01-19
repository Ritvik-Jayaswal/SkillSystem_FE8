.thumb
.equ ChargePlusID, SkillTester+4
.equ MovGetter, ChargePlusID+4
.equ GetUnit,0x8019430

push {r4-r7, lr}
ldr     r5,=0x203a4ec @attacker
cmp     r0,r5
bne     GoBack
mov r4, r0 @atkr
mov r5, r1 @dfdr


@has Charge
ldr r0, SkillTester
mov lr, r0
mov r0, r4 @Attacker data
ldr r1, ChargePlusID
.short 0xf800
cmp r0, #0
beq GoBack

@get unit's move
ldr r0,MovGetter
mov r14,r0
mov r0,r4
mov r1,#0
.short 0xF800
@r0= unit's move *2 for some reason
lsr r0,r0,#1 @r0 = unit's move
mov r6,r0 @r6 = unit's move

@check allegiance
mov r0,r4 @attacker
ldrb r0,[r0,#0xB] @allegiance byte
lsr r0,#6 @just the allegiance
cmp r0,#0
bne AltMovementCheck
@fast, but only works for player units
ldr r3,=0x203a968 @Spaces Moved
ldrb r1,[r3]
b FinishCharge

AltMovementCheck:
@Manhattan distance: |x2-x1| + |y2-y1|
@This correctly matches FE's tile-based movement
ldr r6,=#0x202BE48 @active unit position (has starting coords)

@Calculate |x2-x1|
ldrb r0,[r4,#0x10] @x1 (current X)
ldrh r1,[r6] @x2 (starting X)
sub r1,r0 @r1 = x2 - x1
bpl PosX @if positive, skip negation
neg r1,r1 @make positive
PosX:
mov r3,r1 @r3 = |x2-x1|

@Calculate |y2-y1|
ldrb r0,[r4,#0x11] @y1 (current Y)
ldrh r1,[r6,#0x2] @y2 (starting Y)
sub r1,r0 @r1 = y2 - y1
bpl PosY @if positive, skip negation
neg r1,r1 @make positive
PosY:

add r1,r3 @r1 = |x2-x1| + |y2-y1| = Manhattan distance

FinishCharge:

@get remaining move
mov r0,r6 @r0 = unit's move
sub r0,r1
cmp r0,#0 @see if we've moved as far as possible
bgt GoBack @if not, no bonus

@otherwise, set the brave flag on our weapon
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
@WORD ChargePlusID
@POIN prMovGetter
