import React, { useState } from "react";
import {
  Modal,
  View,
  Text,
  Pressable,
  ScrollView,
  Keyboard,
  TouchableWithoutFeedback,
  TextInput,
  ActivityIndicator,
} from "react-native";
import { faXmark, faMagnifyingGlass } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-native-fontawesome";
import { LSXType } from "../type";
import { getApi } from "../../../Base/api/api_service__";

type LSXModalListProps = {
  handleOpenLSXModalList: () => void;
  onSubmit: (data: LSXType) => void;
  open: boolean;
  title: string;
};

const LSXModalList = (props: LSXModalListProps) => {
  const { handleOpenLSXModalList, onSubmit, open, title } = props;

  const [searchText, setSearchText] = useState("");
  const [dataList, setDataList] = useState<LSXType[]>([]);
  const [loading, setLoading] = useState(false);

  // Fetch LSX list API according to search keyword
  const handleSearchApi = async () => {
    try {
      setLoading(true);
      const url = `/APIMobile/ShiftTestingMFDiscreteJobMobile?strSearch=${encodeURIComponent(
        searchText.trim(),
      )}`;
      const response = await getApi(url, {});
      if (response?.success && response?.data) {
        setDataList(response.data);
      } else {
        setDataList([]);
      }
    } catch (error) {
      console.error("LSX search error:", error);
      setDataList([]);
    } finally {
      setLoading(false);
    }
  };

  const handleChoseLSX = (item: LSXType) => {
    onSubmit(item);
    handleOpenLSXModalList();
  };

  return (
    <Modal animationType="slide" transparent={true} visible={open}>
      <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
        <View className="flex-1 justify-center items-center bg-black/50 px-4">
          <View className="bg-white rounded-[30px] w-full max-w-sm shadow-xl overflow-hidden h-[85%]">
            {/* Header */}
            <View className="flex-row justify-between items-center p-5 border-b border-slate-100">
              <Text className="text-lg font-bold text-slate-800 uppercase tracking-tight">
                {title}
              </Text>
              <Pressable
                className="w-10 h-10 items-center justify-center rounded-full active:bg-slate-100"
                onPress={handleOpenLSXModalList}
              >
                <FontAwesomeIcon icon={faXmark} size={20} color="#64748b" />
              </Pressable>
            </View>

            {/* Body */}
            <View className="p-4 flex-1">
              {/* Search Input & Action Button */}
              <View className="flex-row items-center bg-slate-100 rounded-2xl px-3.5 py-1 mb-3 border border-slate-200">
                <FontAwesomeIcon
                  icon={faMagnifyingGlass}
                  size={16}
                  color="#94a3b8"
                />
                <TextInput
                  value={searchText}
                  onChangeText={setSearchText}
                  onSubmitEditing={handleSearchApi}
                  placeholder="Enter keyword to search..."
                  placeholderTextColor="#94a3b8"
                  className="flex-1 ml-2 text-sm text-slate-800 py-2.5 p-0"
                  returnKeyType="search"
                />
                {searchText !== "" && (
                  <Pressable
                    onPress={() => setSearchText("")}
                    className="p-1 mr-1"
                  >
                    <FontAwesomeIcon icon={faXmark} size={14} color="#94a3b8" />
                  </Pressable>
                )}
                <Pressable
                  onPress={handleSearchApi}
                  className="bg-primary px-3 py-1.5 rounded-xl active:bg-cyan-700"
                >
                  <Text className="text-white text-xs font-bold">Search</Text>
                </Pressable>
              </View>

              {/* Data List or Loading */}
              {loading ? (
                <View className="flex-1 justify-center items-center">
                  <ActivityIndicator size="large" color="#0891b2" />
                </View>
              ) : dataList.length > 0 ? (
                <ScrollView
                  showsVerticalScrollIndicator={false}
                  className="h-full"
                >
                  {dataList.map((item: LSXType, index: number) => (
                    <Pressable
                      onPress={() => handleChoseLSX(item)}
                      key={item.DiscreteID || index}
                      className="border border-slate-200 p-4 rounded-2xl mb-3 bg-white active:bg-cyan-50 shadow-sm"
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
              ) : (
                <View className="h-32 justify-center items-center">
                  <Text className="mt-2 text-slate-400 italic">
                    No data found
                  </Text>
                </View>
              )}
            </View>

            {/* Footer */}
            <View className="p-4 bg-slate-50 flex-row justify-center border-t border-slate-100">
              <Pressable
                onPress={handleOpenLSXModalList}
                className="bg-slate-400 py-3 px-12 rounded-md active:opacity-70 shadow-sm"
              >
                <Text className="text-white font-bold text-center">Close</Text>
              </Pressable>
            </View>
          </View>
        </View>
      </TouchableWithoutFeedback>
    </Modal>
  );
};

export default LSXModalList;
