import React, { useState, useMemo, useEffect } from "react";
import {
  Modal,
  View,
  Text,
  TextInput,
  Pressable,
  ScrollView,
  Keyboard,
  TouchableWithoutFeedback,
  ActivityIndicator,
} from "react-native";
import { AppColors } from "../../../../colors";
import {
  faXmark,
  faMagnifyingGlass,
  faCircleXmark,
} from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-native-fontawesome";
import { UserType } from "../type";
import { getApi } from "../../../Base/api/api_service";
import Toast from "react-native-toast-message";
import Pagination from "../../../Components/Pagination";

type UserModalListProps = {
  handleOpenUserModalList: () => void;
  onSubmit: (data: UserType) => void;
  open: boolean;
  title: string;
};

const UserModalList = (props: UserModalListProps) => {
  const { handleOpenUserModalList, onSubmit, open, title } = props;

  // State dữ liệu gốc từ API
  const [rawData, setRawData] = useState<UserType[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchText, setSearchText] = useState("");

  // State Phân Trang Client
  const [page, setPage] = useState(1);
  const LIMIT = 10;

  // 🚀 Lấy toàn bộ danh sách User từ API
  const fetchUsers = async () => {
    setLoading(true);
    try {
      const url = `/APIMobile/ShiftTestingOwnerMobile`;
      const response = await getApi(url, {});

      console.log("fetchUsers", response);
      if (response?.success && Array.isArray(response.data)) {
        setRawData(response.data);
      } else {
        setRawData([]);
      }
    } catch (error: any) {
      if (error?.status === 404) {
        Toast.show({
          type: "error",
          text1: "Lỗi",
          text2: error.message || "Không tìm thấy danh sách nhân viên",
        });
      }
      setRawData([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (open) {
      setPage(1);
      setSearchText("");
      fetchUsers();
    }
  }, [open]);

  const handleCancel = () => {
    setSearchText("");
    handleOpenUserModalList();
  };

  const handleChooseItem = (item: UserType) => {
    setSearchText("");
    onSubmit(item);
    handleOpenUserModalList();
  };

  // 🔍 1. Lọc danh sách theo từ khóa tìm kiếm
  const filteredData = useMemo(() => {
    if (!searchText.trim()) return rawData;

    const query = searchText.toLowerCase().trim();
    return rawData.filter(
      (item) =>
        item?.UserName?.toString().toLowerCase().includes(query) ||
        item?.DisplayName?.toLowerCase().includes(query) ||
        item?.FullName?.toLowerCase().includes(query),
    );
  }, [rawData, searchText]);

  // 📄 2. Tính tổng số trang dựa trên kết quả đã filter
  const totalPage = useMemo(() => {
    return Math.ceil(filteredData.length / LIMIT) || 0;
  }, [filteredData]);

  // ✂️ 3. Cắt mảng lấy danh sách hiển thị cho Trang hiện tại
  const displayData = useMemo(() => {
    const startIndex = (page - 1) * LIMIT;
    return filteredData.slice(startIndex, startIndex + LIMIT);
  }, [filteredData, page]);

  // Reset về trang 1 mỗi khi người dùng nhập từ khóa tìm kiếm mới
  const handleSearchChange = (text: string) => {
    setSearchText(text);
    setPage(1);
  };

  return (
    <Modal animationType="slide" transparent={true} visible={open}>
      <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
        <View className="flex-1 justify-center items-center bg-black/50 px-4">
          <View className="bg-white rounded-[30px] w-full max-w-sm shadow-xl overflow-hidden">
            {/* Header */}
            <View className="flex-row justify-between items-center px-5 py-3 border-b border-slate-100">
              <Text className="text-lg font-bold text-slate-800 uppercase tracking-tight">
                {title}
              </Text>
              <Pressable
                className="w-10 h-10 items-center justify-center rounded-full active:bg-slate-100"
                onPress={handleCancel}
              >
                <FontAwesomeIcon icon={faXmark} size={20} color="#64748b" />
              </Pressable>
            </View>

            {/* 🔍 Search Input */}
            <View className="px-4 pt-3">
              <View className="flex-row items-center bg-slate-100 rounded-2xl px-3 h-10 border border-slate-200">
                <FontAwesomeIcon
                  icon={faMagnifyingGlass}
                  size={16}
                  color="#94a3b8"
                />
                <TextInput
                  className="flex-1 ml-2 text-sm text-slate-800 font-medium h-full py-0"
                  placeholder="Tìm theo mã, tên nhân viên..."
                  placeholderTextColor="#94a3b8"
                  value={searchText}
                  onChangeText={handleSearchChange}
                  autoCapitalize="none"
                  autoCorrect={false}
                />
                {searchText.length > 0 && (
                  <Pressable
                    onPress={() => handleSearchChange("")}
                    className="p-1"
                  >
                    <FontAwesomeIcon
                      icon={faCircleXmark}
                      size={16}
                      color="#94a3b8"
                    />
                  </Pressable>
                )}
              </View>
            </View>

            {/* Body */}
            <View className="p-4">
              {loading ? (
                <View className="h-72 justify-center items-center">
                  <ActivityIndicator color={AppColors.primary} size="large" />
                  <Text className="mt-2 text-slate-400 italic">
                    Đang tải...
                  </Text>
                </View>
              ) : displayData.length > 0 ? (
                <View className="h-72">
                  <ScrollView
                    showsVerticalScrollIndicator={false}
                    keyboardShouldPersistTaps="handled"
                  >
                    {displayData.map((item: UserType, index: number) => (
                      <Pressable
                        onPress={() => handleChooseItem(item)}
                        key={item?.UserName || index}
                        className="border border-slate-200 p-3 rounded-2xl mb-2.5 bg-white active:bg-cyan-50 shadow-sm"
                      >
                        <View className="flex-row items-center">
                          <Text className="w-16 text-xs font-bold text-slate-400 uppercase">
                            User:
                          </Text>
                          <Text
                            className="flex-1 font-bold text-cyan-700 text-sm"
                            numberOfLines={1}
                          >
                            {item?.DisplayName || item?.UserName}
                          </Text>
                        </View>
                      </Pressable>
                    ))}
                  </ScrollView>
                </View>
              ) : (
                <View className="h-72 justify-center items-center">
                  <Text className="text-slate-400 italic text-sm">
                    Không tìm thấy nhân viên phù hợp
                  </Text>
                </View>
              )}
            </View>

            {/* Pagination Component */}
            {totalPage > 1 && (
              <View className="px-3 pb-2">
                <Pagination
                  page={page}
                  totalPage={totalPage}
                  onPageChange={(newPage) => setPage(newPage)}
                />
              </View>
            )}

            {/* Footer */}
            <View className="py-2 px-4 bg-slate-50 flex-row justify-center border-t border-slate-100">
              <Pressable
                onPress={handleCancel}
                className="bg-red-500 py-3 px-10 rounded-xl active:opacity-70 shadow-sm"
              >
                <Text className="text-white font-bold text-center">Cancel</Text>
              </Pressable>
            </View>
          </View>
        </View>
      </TouchableWithoutFeedback>
    </Modal>
  );
};

export default UserModalList;
