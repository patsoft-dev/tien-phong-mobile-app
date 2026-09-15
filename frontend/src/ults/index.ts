import { Platform, Dimensions } from "react-native";

export const device = {
  width: Dimensions.get("window").width,
  height: Dimensions.get("window").height,
  os: Platform.OS,
};

export const formatMonth = (date: Date) => {
  return date.getMonth() + 1 + "/" + date.getFullYear();
};

export const formatDate = (date: Date) => {
  return (
    date.getDate() + "/" + (date.getMonth() + 1) + "/" + date.getFullYear()
  );
};
// export const formatTime = (date: Date) => {
//     return date.getHours() + ':' + date.getMinutes();
// };
export const formatTime = (
  dateString: string | Date | null | undefined,
  includeSeconds: boolean = true,
): string => {
  if (!dateString) return "--:--";

  try {
    const date = new Date(dateString);

    // Kiểm tra tính hợp lệ của Date
    if (isNaN(date.getTime())) return "--:--";

    const hours = String(date.getHours()).padStart(2, "0");
    const minutes = String(date.getMinutes()).padStart(2, "0");

    if (includeSeconds) {
      const seconds = String(date.getSeconds()).padStart(2, "0");
      return `${hours}:${minutes}:${seconds}`; // Kết quả: 17:35:25
    }

    return `${hours}:${minutes}`; // Kết quả: 17:35
  } catch (error) {
    console.error("❌ Lỗi formatTimeOnly:", error);
    return "--:--";
  }
};

export const formatDateToApi = (dateInput: Date | string) => {
  if (!dateInput) return "";

  if (typeof dateInput === "string") {
    if (/^\d{4}[-/]\d{2}[-/]\d{2}$/.test(dateInput.trim())) {
      const [year, month, day] = dateInput.trim().split(/[-/]/);
      return `${day}/${month}/${year}`;
    }
  }

  const date = typeof dateInput === "string" ? new Date(dateInput) : dateInput;
  if (isNaN(date.getTime())) return "";

  const day = String(date.getDate()).padStart(2, "0");
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const year = date.getFullYear();

  return `${day}/${month}/${year}`;
};
