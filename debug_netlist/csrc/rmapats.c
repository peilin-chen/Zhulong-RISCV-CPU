#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

scalar dummyScalar;
scalar fScalarIsForced=0;
scalar fScalarIsReleased=0;
scalar fScalarHasChanged=0;
scalar fForceFromNonRoot=0;
void  hsG_0(struct dummyq_struct * I971, EBLK  * I972, U  I702);
void  hsG_0(struct dummyq_struct * I971, EBLK  * I972, U  I702)
{
    U  I1178;
    U  I1179;
    U  I1180;
    struct futq * I1181;
    I1178 = ((U )vcs_clocks) + I702;
    I1180 = I1178 & 0xfff;
    I972->I635 = (EBLK  *)(-1);
    I972->I639 = I1178;
    if (I1178 < (U )vcs_clocks) {
        I1179 = ((U  *)&vcs_clocks)[1];
        sched_millenium(I971, I972, I1179 + 1, I1178);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I702 == 1)) {
        I972->I640 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I635 = I972;
        peblkFutQ1Tail = I972;
    }
    else if ((I1181 = I971->I937[I1180].I652)) {
        I972->I640 = (struct eblk *)I1181->I651;
        I1181->I651->I635 = (RP )I972;
        I1181->I651 = (RmaEblk  *)I972;
    }
    else {
        sched_hsopt(I971, I972, I1178);
    }
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
