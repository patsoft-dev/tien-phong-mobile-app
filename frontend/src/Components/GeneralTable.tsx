import React from "react";
import {
  Dimensions,
  ScrollView,
  Text,
  TouchableOpacity,
  View,
} from "react-native";
const { width: screenWidth } = Dimensions.get("window");

export interface TableColumn {
  name: string;
  label: string;
  width?: number;
}

interface GeneralTableProps {
  data: any[];
  columns: TableColumn[];
  selectedColumns: string[];
  onRowPress?: (item: any, index: number) => void;
  renderCell?: (
    columnName: string,
    item: any,
    index: number,
  ) => React.ReactNode;
  // 🌟 Thêm prop tùy chọn để format màu hàng theo điều kiện item
  getRowClassName?: (item: any, index: number) => string;
}

const GeneralTable = ({
  data,
  columns,
  selectedColumns,
  onRowPress,
  renderCell,
  getRowClassName,
}: GeneralTableProps) => {
  const visibleColumns = columns.filter((col) =>
    selectedColumns.includes(col.name),
  );

  return (
    <View className="flex-1 bg-white">
      <ScrollView horizontal showsHorizontalScrollIndicator={true}>
        <View className="flex-col">
          {/* Header table */}
          <View className="flex-row bg-primary py-3 border-b border-gray-200">
            {visibleColumns.map((col, index) => (
              <View
                key={col.name}
                className={`items-center justify-center ${
                  index < visibleColumns.length - 1
                    ? "border-r border-white/20"
                    : ""
                }`}
                style={{ width: col.name === "STT" ? 60 : col.width || 100 }}
              >
                <Text className="text-white font-bold">{col.label}</Text>
              </View>
            ))}
          </View>

          {/* Body table */}
          <ScrollView className="flex-col">
            {data?.length > 0 ? (
              data.map((value: any, key: number) => {
                // 🌟 Lấy class tùy chỉnh từ prop (nếu có)
                const customRowClass = getRowClassName
                  ? getRowClassName(value, key)
                  : "";
                const defaultBg = key % 2 === 0 ? "bg-white" : "bg-gray-50";

                return (
                  <TouchableOpacity
                    key={key}
                    onPress={() => onRowPress && onRowPress(value, key)}
                    className={`flex-row items-center border-b border-gray-200 py-3 ${
                      customRowClass || defaultBg
                    }`}
                  >
                    {visibleColumns.map((col) => {
                      if (col.name === "STT") {
                        return (
                          <View
                            key="STT"
                            className="items-center justify-center border-r border-gray-200"
                            style={{ width: 60 }}
                          >
                            <Text className="text-gray-700">{key + 1}</Text>
                          </View>
                        );
                      }

                      const customContent = renderCell
                        ? renderCell(col.name, value, key)
                        : null;

                      return (
                        <View
                          key={col.name}
                          style={{ width: col.width || 100 }}
                          className="items-center justify-center border-r border-gray-200"
                        >
                          {customContent !== null &&
                          customContent !== undefined ? (
                            customContent
                          ) : (
                            <Text className="text-gray-700 text-center">
                              {value[col.name] !== undefined
                                ? String(value[col.name])
                                : ""}
                            </Text>
                          )}
                        </View>
                      );
                    })}
                  </TouchableOpacity>
                );
              })
            ) : (
              <View
                style={{ width: screenWidth }}
                className="p-10 items-center justify-center"
              >
                <Text className="text-gray-400">Không có dữ liệu</Text>
              </View>
            )}
          </ScrollView>
        </View>
      </ScrollView>
    </View>
  );
};

export default GeneralTable;
