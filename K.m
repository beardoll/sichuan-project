capacity = [4100 5200 5200 6200];
carnum = [10 8 9 7];

Lx = [21133 937 13304 12501 3206 2854 7361 907 18503 11216 4731 13986 7201 ...
      13916 17589 15351 5193 22849 9830 17178 656 2473 17630 7080 5484 ...
      12119 4601 21795 7572 16244 6920 375 19095 2744 12761 3838 4230 7793 ...
      9740 19236 22307 19005 10312 11306 14066 556 2373 15662 15120 12621 ...
      21534 20480 13645 19095 8255 13374 21534 7873 22147 6799 2684 15130 ...
      3386 12651 17268 4480 12149 19105 5183 12380 12330 13494 2603 2724 15823];
Ly = [26347 7815 18492 17765 19145 15845 25644 15406 6648 29710 20023 11930 ...
      3900 4804 16673 21679 26297 15820 638 400 28179 18154 17313 22432 ...
      25293 26498 21040 13173 1980 25895 26861 17313 3637 1391 20525 20249 ...
      15306 28028 16021 7025 21328 500 29095 21981 7802 24201 14791 20864 ...
      18718 24176 17451 18016 9471 15117 22821 28831 25105 12068 15243 8354 ...
      20663 425 10111 1278 11190 24528 22119 22997 11378 10124 6661 28204 ...
      6272 1554 8430];
demandL = [572 478 524 239 827 430 433 294 695 789 558 56 577 861 305 739 ...
           675 648 453 329 382 544 415 636 898 557 190 253 630 480 582 182 ...
           580 513 580 426 737 663 394 380 505 526 621 441 691 496 659 626 ...
           485 578 509 518 293 380 573 125 711 890 849 40 343 114 542 666 ...
           391 449 637 409 649 498 551 265 317 661 679];
       
Bx = [520 16952 3933 11933 2689 4817 6834 17334 3472 270 2789 340 15186 ...
      15908 3271 21268 1584 15206 20877 20154 23266 10759 19361 9032 19421 ...
      13760 10478 23657 2648 12807 6543 4064 8701 19933 19592 10568 1615 22613];
By = [15073 25287 24797 6102 22689 26190 28963 1246 4797 27231 29879 19666 ...
      5563 13982 12413 15876 10908 1309 21786 5098 5701 3731 12865 2551 ...
      4459 6817 519 22752 22401 25437 29967 20920 14396 14459 26077 11924 ...
      26014 19101];
demandB = [794 890 294 428 362 608 737 174 387 483 440 480 268 722 409 755 ...
           220 729 640 585 33 489 732 184 510 219 692 745 642 311 507 470 ...
           442 561 390 147 506 578];
  
filename = 'KPro';
save(filename, 'Lx', 'Ly', 'demandL', 'Bx', 'By', 'demandB', 'capacity', 'carnum');