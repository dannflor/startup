export default function getNeighbors(index) {
  switch (index) {
    case 0:
      return [1, 2];
    case 1:
      return [0, 3, 4];
    case 2:
      return [0, 4, 5];
    case 3:
      return [1, 6, 7];
    case 4:
      return [1, 2, 7, 8];
    case 5:
      return [2, 8, 9];
    case 6:
      return [3, 10, 11];
    case 7:
      return [3, 4, 11, 12];
    case 8:
      return [4, 5, 12, 13];
    case 9:
      return [5, 13, 14];
    case 10:
      return [6, 15, 16];
    case 11:
      return [6, 7, 16, 17];
    case 12:
      return [7, 8, 17, 18];
    case 13:
      return [8, 9, 18, 19];
    case 14:
      return [9, 19, 20];
    case 15:
      return [10, 21, 22];
    case 16:
      return [10, 11, 22, 23];
    case 17:
      return [11, 12, 23, 24];
    case 18:
      return [12, 13, 24, 25];
    case 19:
      return [13, 14, 25, 26];
    case 20:
      return [14, 26, 27];
    case 21:
      return [15, 28];
    case 22:
      return [15, 16, 28, 29];
    case 23:
      return [16, 17, 29, 30];
    case 24:
      return [17, 18, 30, 31];
    case 25:
      return [18, 19, 31, 32];
    case 26:
      return [19, 20, 32, 33];
    case 27:
      return [20, 33];
    case 28:
      return [21, 22, 34];
    case 29:
      return [22, 23, 34, 35];
    case 30:
      return [23, 24, 35, 36];
    case 31:
      return [24, 25, 36, 37];
    case 32:
      return [25, 26, 37, 38];
    case 33:
      return [26, 27, 38];
    case 34:
      return [28, 29, 39];
    case 35:
      return [29, 30, 39, 40];
    case 36:
      return [30, 31, 40, 41];
    case 37:
      return [31, 32, 41, 42];
    case 38:
      return [32, 33, 42];
    case 39:
      return [34, 35, 43];
    case 40:
      return [35, 36, 43, 44];
    case 41:
      return [36, 37, 44, 45];
    case 42:
      return [37, 38, 45];
    case 43:
      return [39, 40, 46];
    case 44:
      return [40, 41, 46, 47];
    case 45:
      return [41, 42, 47];
    case 46:
      return [43, 44, 48];
    case 47:
      return [44, 45, 48];
    case 48:
      return [46, 47];
  
    default:
      return 0;
  }
}