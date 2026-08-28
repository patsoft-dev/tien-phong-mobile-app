// recoil/settingStore.ts
import { atom } from "recoil";

export const settingStore = atom({
  key: "settingStore",
  default: {
    useCameraScan: true, // false = dùng thiết bị, true = dùng camera
  },
});
