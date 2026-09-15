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
import { LSXType } from "../type";
import { getApi } from "../../../Base/api/api_service__";
import Toast from "react-native-toast-message";

type LSXModalListProps = {
  handleOpenLSXModalList: () => void;
  onSubmit: (data: LSXType) => void;
  open: boolean;
  title: string;
};

const LSXModalList = (props: LSXModalListProps) => {
  const { handleOpenLSXModalList, onSubmit, open, title } = props;

  const [dataList, setDataList] = useState<LSXType[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchText, setSearchText] = useState("");

  // 🚀 Gọi API lấy danh sách LSX có kèm từ khóa strSearch
  const fetchLSX = async (searchQuery: string = "") => {
    setLoading(true);
    try {
      const url = `/APIMobile/ShiftTestingMFDiscreteJobMobile?strSearch=${encodeURIComponent(
        searchQuery.trim(),
      )}`;
      const response = await getApi(url, {});

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
          text2: error.message || "Không tìm thấy dữ liệu LSX",
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
        fetchLSX(searchText);
      } else {
        setDataList([]);
      }
    } else {
      setSearchText("");
      setDataList([]);
    }
  }, [open]);

  // Nút tìm kiếm bên cạnh ô Input
  const handleSearch = () => {
    Keyboard.dismiss();
    fetchLSX(searchText);
  };

  const handleClearSearch = () => {
    setSearchText("");
    fetchLSX("");
  };

  const handleCancel = () => {
    setSearchText("");
    handleOpenLSXModalList();
  };

  const handleChooseItem = (item: LSXType) => {
    setSearchText("");
    onSubmit(item);
    handleOpenLSXModalList();
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
                    placeholder="Tìm kiếm LSX..."
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
                    {dataList.map((item: LSXType, index: number) => (
                      <Pressable
                        onPress={() => handleChooseItem(item)}
                        key={item?.DiscreteID || index}
                        className="border border-slate-200 p-3 rounded-2xl mb-2.5 bg-white active:bg-cyan-50 shadow-sm"
                      >
                        <View className="flex-row items-center mb-1">
                          <Text className="w-24 text-xs font-bold text-slate-400 uppercase">
                            Discrete ID:
                          </Text>
                          <Text
                            className="flex-1 font-bold text-cyan-700 text-sm"
                            numberOfLines={1}
                          >
                            {item?.DiscreteID}
                          </Text>
                        </View>
                        <View className="flex-row items-center">
                          <Text className="w-24 text-xs font-bold text-slate-400 uppercase">
                            Discrete Nbr:
                          </Text>
                          <Text className="flex-1 font-bold text-slate-700 text-sm">
                            {item?.DiscreteNbr}
                          </Text>
                        </View>
                      </Pressable>
                    ))}
                  </ScrollView>
                </View>
              ) : (
                <View className="h-80 justify-center items-center">
                  <Text className="text-slate-400 italic text-sm">
                    Không tìm thấy dữ liệu phù hợp
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

export default LSXModalList;
