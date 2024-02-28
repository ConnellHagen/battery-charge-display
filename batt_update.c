// THIS FILE IS INCLUDED TO BE USED WITH HYBRID_MAIN FOR TESTING
// Copy your batt_update.c solution to part1 into this file to test C alongside assembly code.
// The compiler will mix functions from batt_update_asm.s and batt_update.c if you
// comment out the version not to be used by the compiler when running 'make hybrid_main'.
// only ONE version of each function should be defined between the asm and c file!

#include "batt.h"


// int set_batt_from_ports(batt_t *batt){
//   return -1;
// } 

// int set_display_from_batt(batt_t batt, int* display)
// {
//     int display_masks[11] =
//     {
//         0b0111111, // 0
//         0b0000110, // 1
//         0b1011011, // 2
//         0b1001111, // 3
//         0b1100110, // 4
//         0b1101101, // 5
//         0b1111101, // 6
//         0b0000111, // 7
//         0b1111111, // 8
//         0b1101111, // 9
//         0b0000000  // empty
//     };

//     int t_disp = 0;
    
//     // bits 24-28: battery percentage indicator
//     if(batt.percent >= 90)      t_disp = 0b11111;
//     else if(batt.percent >= 70) t_disp = 0b01111;
//     else if(batt.percent >= 50) t_disp = 0b00111;
//     else if(batt.percent >= 30) t_disp = 0b00011;
//     else if(batt.percent >= 5)  t_disp = 0b00001;
//     else                        t_disp = 0b00000;

//     if(batt.mode == 2) // voltage mode
//     {
//         int digit_1_offset = batt.mlvolts % 1000;
//         int digit_2_offset = digit_1_offset % 100;
//         int digit_3_offset = digit_2_offset % 10;
//         int digit_3_rounding = 0;
//             if(digit_3_offset >= 5) digit_3_rounding = 1;
//         int digits[3] = {
//             (batt.mlvolts - digit_1_offset) / 1000,
//             (digit_1_offset - digit_2_offset) / 100,
//             (digit_2_offset - digit_3_offset) / 10 + digit_3_rounding
//         };

//         // bits 3-23: digits
//         for(int i = 0; i < 3; i++)
//         {
//             t_disp = t_disp << 7;
//             t_disp = t_disp | display_masks[digits[i]];
//         }
        
//         // bits 0-2: voltage/percent, decimal indicators
//         t_disp = t_disp << 3;
//         t_disp = t_disp | 0b110;

//     }
//     else // percentage mode
//     {
//         int digit_1_offset = batt.percent % 100;
//         int digit_2_offset = digit_1_offset % 10;
//         int digits[3] = {
//             (batt.percent - digit_1_offset) / 100,
//             (digit_1_offset - digit_2_offset) / 10,
//             digit_2_offset
//         };

//         int digits_started = 0;

//         // bits 3-23: digits
//         for(int i = 0; i < 3; i++)
//         {
//             t_disp = t_disp << 7;

//             if(i == 2) digits_started = 1;

//             if(digits_started == 0 && digits[i] == 0)
//             {
//                 t_disp = t_disp | display_masks[10];
//             }
//             else
//             {
//                 digits_started = 1;
//                 t_disp = t_disp | display_masks[digits[i]];
//             }
//         }

//         // bits 0-2: voltage/percent, decimal indicators
//         t_disp = t_disp << 3;
//         t_disp = t_disp | 0b001;
//     }

//     *display = t_disp;

//     return 0;
// }

// int batt_update()
// {
//     int display;
//     batt_t battery;

//     if(set_batt_from_ports(&battery) != 0) return 1;
//     if(set_display_from_batt(battery, &display) != 0) return 1;

//     BATT_DISPLAY_PORT = display;

//     return 0;
// }
