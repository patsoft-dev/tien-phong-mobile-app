import React, { useState, useEffect } from "react";
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
import { getApi } from "../../../Base/api/api_service__";
import Toast from "react-native-toast-message";

type UserModalListProps = {
  handleOpenUserModalList: () => void;
  onSubmit: (data: UserType) => void;
  open: boolean;
  title: string;
};

const UserModalList = (props: UserModalListProps) => {
  const { handleOpenUserModalList, onSubmit, open, title } = props;

  const [dataList, setDataList] = useState<UserType[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchText, setSearchText] = useState("");

  // Hàm hỗ trợ chuyển tiếng Việt có dấu thành không dấu
  const removeVietnameseTones = (str: string): string => {
    return str
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/đ/g, "d")
      .replace(/Đ/g, "D");
  };

  const fetchUsers = async (searchQuery: string = "") => {
    setLoading(true);
    try {
      // Chuyển "thắng" -> "thang"
      const unaccentedQuery = removeVietnameseTones(searchQuery.trim());

      const url = `/APIMobile/ShiftTestingOwnerMobile?strSearch=${encodeURIComponent(
        unaccentedQuery,
      )}`;

      const response = await getApi(url, {});
      // ... giữ nguyên đoạn bên dưới

      console.log("fetchUsers response:", response);
      console.log("url:", url);

      if (response?.success && Array.isArray(response.data)) {
        setDataList(response.data);
      } else {
        setDataList([]);
      }
    } catch (error: any) {
      if (error?.status === 404) {
        Toast.show({
          type: "error",
          text1: "Lỗi",
          text2: error.message || "Không tìm thấy danh sách nhân viên",
        });
      }
      setDataList([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (open) {
      if (searchText.trim()) {
        // Nếu đã có searchText sẵn thì mới gọi API
        fetchUsers(searchText);
      } else {
        // Nếu chưa có searchText thì clear danh sách cũ
        setDataList([]);
      }
    } else {
      // Khi đóng modal thì reset lại input và danh sách
      setSearchText("");
      setDataList([]);
    }
  }, [open]);

  // Nút tìm kiếm bên cạnh ô Input
  const handleSearch = () => {
    Keyboard.dismiss();
    fetchUsers(searchText);
  };

  const handleClearSearch = () => {
    setSearchText("");
    fetchUsers("");
  };

  const handleCancel = () => {
    setSearchText("");
    handleOpenUserModalList();
  };

  const handleChooseItem = (item: UserType) => {
    setSearchText("");
    onSubmit(item);
    handleOpenUserModalList();
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

            {/* 🔍 Search Input + Button Kính lúp */}
            <View className="px-4 pt-3">
              <View className="flex-row items-center space-x-2">
                <View className="flex-1 flex-row items-center bg-slate-100 rounded-2xl px-3 h-11 border border-slate-200">
                  <TextInput
                    className="flex-1 text-sm text-slate-800 font-medium h-full py-0"
                    placeholder="Tìm theo mã, tên nhân viên..."
                    placeholderTextColor="#94a3b8"
                    value={searchText}
                    onChangeText={setSearchText}
                    onSubmitEditing={handleSearch}
                    returnKeyType="search"
                    autoCapitalize="none"
                    autoCorrect={false}
                  />
                  {searchText.length > 0 && (
                    <Pressable onPress={handleClearSearch} className="p-1">
                      <FontAwesomeIcon
                        icon={faCircleXmark}
                        size={16}
                        color="#94a3b8"
                      />
                    </Pressable>
                  )}
                </View>

                {/* Nút bấm Tìm kiếm */}
                <Pressable
                  onPress={handleSearch}
                  className="bg-primary w-11 h-11 rounded-2xl items-center justify-center shadow-sm active:opacity-80"
                >
                  <FontAwesomeIcon
                    icon={faMagnifyingGlass}
                    size={16}
                    color="#ffffff"
                  />
                </Pressable>
              </View>
            </View>

            {/* Body */}
            <View className="p-4">
              {loading ? (
                <View className="h-80 justify-center items-center">
                  <ActivityIndicator color={AppColors.primary} size="large" />
                  <Text className="mt-2 text-slate-400 italic text-xs">
                    Đang tải dữ liệu...
                  </Text>
                </View>
              ) : dataList.length > 0 ? (
                <View className="h-80">
                  <ScrollView
                    showsVerticalScrollIndicator={false}
                    keyboardShouldPersistTaps="handled"
                  >
                    {dataList.map((item: UserType, index: number) => (
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
                <View className="h-80 justify-center items-center">
                  <Text className="text-slate-400 italic text-sm">
                    Không tìm thấy nhân viên phù hợp
                  </Text>
                </View>
              )}
            </View>

            {/* Footer */}
            <View className="py-3 px-4 bg-slate-50 flex-row justify-center border-t border-slate-100">
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
