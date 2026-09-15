import React, { useCallback, useEffect, useState } from "react";
import { View, Text, TouchableOpacity, Pressable } from "react-native";
import HeaderComponent from "../../Base/HeaderComponent/headerComponent";
import { useNavigation, useFocusEffect } from "@react-navigation/native";
import { FontAwesomeIcon } from "@fortawesome/react-native-fontawesome";
import {
  faCalendarDays,
  faMagnifyingGlass,
  faPlus,
  faRotateLeft,
  faUser,
  faXmark,
} from "@fortawesome/free-solid-svg-icons";
import { formatDate, formatDateToApi, formatTime } from "../../ults";
import { useSetRecoilState } from "recoil";
import { loadingStore } from "../../Store/loadingStore";
import { TypeFormQCHeader, UserType } from "./type";
import { getApi } from "../../Base/api/api_service__";
import {
  QualityControlDetailAtom,
  QualityControlDetailID,
  QualityControlStatusTypeAtom,
} from "./store";
import GeneralTable, { TableColumn } from "../../Components/GeneralTable";
import Pagination from "../../Components/Pagination";
import { AppColors } from "../../../colors";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import DatePicker from "react-native-date-picker";
import UserModalList from "./Modal/UserModal";

const QualityControlList = () => {
  const setLoadingAtom = useSetRecoilState(loadingStore);
  const setQualityControlStatusTypeAtom = useSetRecoilState(
    QualityControlStatusTypeAtom,
  );
  const setQualityControlDetailAtom = useSetRecoilState(
    QualityControlDetailAtom,
  );
  const setQualityControlDetailID = useSetRecoilState(QualityControlDetailID);
  const navigate = useNavigation();

  // 🗓️ Ngày mặc định (Đầu tháng đến Cuối tháng)
  const now = new Date();
  const firstDayOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
  const lastDayOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);

  const [openFromDate, setOpenFromDate] = useState(false);
  const [fromDate, setFromDate] = useState<Date>(firstDayOfMonth);
  const [openToDate, setOpenToDate] = useState(false);
  const [toDate, setToDate] = useState<Date>(lastDayOfMonth);
  const [userModal, setUserModal] = useState(false);

  const [list, setList] = useState<TypeFormQCHeader[]>([]);
  const [totalPage, setTotalPage] = useState(0);

  const [params, setParams] = useState({
    fromDate: firstDayOfMonth,
    toDate: lastDayOfMonth,
    page: 1,
    pageSize: 20,
    owner: "",
    username: "",
  });

  // 🗓️ Format ngày dạng DD/MM/YYYY chuẩn Local Time

  //#region Table Config
  const columns: TableColumn[] = [
    { name: "STT", label: "No", width: 50 },
    { name: "TestingNbr", label: "TestingNbr", width: 120 },
    { name: "InventoryCD", label: "InventoryCD", width: 120 },
    { name: "ProductionStandard", label: "ProductionStandard", width: 200 },
    { name: "InspectionTime", label: "InspectionTime", width: 120 },
    { name: "TestingDate", label: "TestingDate", width: 120 },
    { name: "Description", label: "Description", width: 200 },
    { name: "Conclude", label: "Conclude", width: 100 },
    { name: "Owner", label: "Owner", width: 140 },
  ];

  const [selectedColumns] = useState<string[]>([
    "STT",
    "TestingNbr",
    "InventoryCD",
    "ProductionStandard",
    "InspectionTime",
    "TestingDate",
    "Description",
    "Conclude",
    "Owner",
    "Actions_Right",
  ]);

  // Hàm xử lý hiển thị cell đặc biệt
  const renderCustomCell = (columnName: string, item: any) => {
    if (columnName === "TestingNbr") {
      return (
        <Text className="text-gray-700 font-medium">{item.TestingNbr}</Text>
      );
    }
    if (columnName === "tinhTrang") {
      if (item.tinhTrang === "draft") {
        return <Text className="font-semibold text-accent">Lưu tạm</Text>;
      }
      if (item.tinhTrang === "complete") {
        return <Text className="font-semibold text-green-500">Hoàn thành</Text>;
      }
      return <Text className="text-gray-700">{item.tinhTrang}</Text>;
    }
    if (columnName === "TestingDate") {
      return (
        <Text className="text-gray-700">
          {formatDate(new Date(item.TestingDate))}
        </Text>
      );
    }
    if (columnName === "gioKiem") {
      return (
        <Text className="text-gray-700">
          {formatTime(item.ngayKiem, false)}
        </Text>
      );
    }
    if (columnName === "Owner") {
      return <Text className="text-gray-900 font-semibold">{item.Owner}</Text>;
    }

    if (columnName === "Conclude") {
      return (
        <Text
          className={`font-bold ${
            item.Conclude === "K" ? "text-red-600" : "text-gray-700"
          }`}
        >
          {item.Conclude}
        </Text>
      );
    }

    return <Text className="text-gray-700">{item[columnName]}</Text>;
  };
  //#endregion

  // 🚀 Gọi API Lấy Danh Sách Tối Ưu
  const getList = async (searchParams: typeof params) => {
    // setLoadingAtom(true);
    try {
      const url = "/APIMobile/ShiftTestingsPaging";
      const apiQueryParams = {
        page: searchParams.page,
        pageSize: searchParams.pageSize,
        fromDate: formatDateToApi(searchParams.fromDate),
        toDate: formatDateToApi(searchParams.toDate),
        owner: searchParams.owner || "",
      };

      console.log("--> Search Params gửi API: ", apiQueryParams);

      const response = await getApi(url, apiQueryParams);

      if (response?.success && response?.data) {
        const itemObj = response.data.Item;
        const rawArray = itemObj?.Data || [];
        setList(rawArray);
        setTotalPage(itemObj?.TotalPages || 0);
      } else {
        setList([]);
        setTotalPage(0);
      }
    } catch (error: any) {
      console.error("❌ Lỗi xảy ra tại hàm getList:", error);
      setList([]);
      setTotalPage(0);
    } finally {
      // Đảm bảo luôn tắt Loading
      // setLoadingAtom(false);
    }
  };

  const handleUserModal = () => {
    setUserModal((prev) => !prev);
  };

  const handleSearch = () => {
    if (params.page !== 1) {
      setParams((prev) => ({ ...prev, page: 1 }));
    } else {
      getList(params);
    }
  };

  const handleResetFilter = () => {
    setFromDate(firstDayOfMonth);
    setToDate(lastDayOfMonth);
    setParams({
      fromDate: firstDayOfMonth,
      toDate: lastDayOfMonth,
      owner: "",
      username: "",
      page: 1,
      pageSize: 20,
    });
  };

  // 🌟 DUY NHẤT 1 useEffect lắng nghe sự thay đổi của params
  useEffect(() => {
    getList(params);
  }, [params]);

  // Khi quay lại màn hình từ trang chi tiết
  useFocusEffect(
    useCallback(() => {
      getList(params);
    }, []),
  );

  const handleEdit = (item: TypeFormQCHeader) => {
    setQualityControlStatusTypeAtom("EDIT");
    setQualityControlDetailID(item.TestingNbr || "");
    navigate.navigate("DetailQualityControl" as never);
  };

  const insets = useSafeAreaInsets();

  return (
    <View
      className="flex-1 bg-gray-100"
      style={{ paddingBottom: insets.bottom }}
    >
      <HeaderComponent
        backButton={true}
        handleBack={() => navigate.goBack()}
        title="QA/QC List"
        iconRight={
          <View className="flex-row items-center space-x-1">
            <TouchableOpacity
              onPress={() => {
                setQualityControlStatusTypeAtom("NEW");
                setQualityControlDetailAtom({} as TypeFormQCHeader);
                navigate.navigate("DetailQualityControl" as never);
              }}
              className="p-2"
            >
              <FontAwesomeIcon
                icon={faPlus}
                size={22}
                color={AppColors.primary}
              />
            </TouchableOpacity>
          </View>
        }
      />

      {/* Filter Header */}
      <View className="bg-white p-3 border-b border-slate-200 shadow-sm space-y-2">
        <View className="flex-row items-center space-x-2">
          <View className="flex-1">
            <Pressable
              onPress={handleUserModal}
              className="flex-row items-center justify-between bg-slate-50 border border-slate-200 rounded-xl px-3 h-12 active:bg-slate-100"
            >
              <Text
                numberOfLines={1}
                className="text-xs font-semibold text-slate-800 flex-1 mr-1"
              >
                {params.username ? params.username : "Chọn người dùng"}
              </Text>
              {params.username ? (
                <TouchableOpacity
                  onPress={(e) => {
                    e.stopPropagation();
                    setParams((prev) => ({
                      ...prev,
                      owner: "",
                      username: "",
                      page: 1,
                    }));
                  }}
                >
                  <FontAwesomeIcon icon={faXmark} size={14} color="#94a3b8" />
                </TouchableOpacity>
              ) : (
                <FontAwesomeIcon
                  icon={faUser}
                  color={AppColors.secondary}
                  size={13}
                />
              )}
            </Pressable>
          </View>

          {/* Nút Reset (Xóa lọc) */}
          <TouchableOpacity
            onPress={handleResetFilter}
            className="w-12 h-12 bg-slate-100 rounded-xl items-center justify-center border border-slate-200 active:bg-slate-200"
          >
            <FontAwesomeIcon icon={faRotateLeft} color="#64748b" size={14} />
          </TouchableOpacity>

          {/* Nút Tìm kiếm (Search) */}
          <TouchableOpacity
            onPress={handleSearch}
            className="bg-primary w-12 h-12 rounded-xl items-center justify-center shadow-sm active:opacity-80"
          >
            <FontAwesomeIcon
              icon={faMagnifyingGlass}
              color="#ffffff"
              size={14}
            />
          </TouchableOpacity>
        </View>

        <View className="flex-row items-center space-x-2">
          {/* Ô Từ ngày */}
          <View className="flex-1">
            <Pressable
              onPress={() => setOpenFromDate(true)}
              className="flex-row items-center justify-between bg-slate-50 border border-slate-200 rounded-xl px-3 h-12 active:bg-slate-100"
            >
              <Text className="text-slate-800 text-xs font-semibold">
                {fromDate ? formatDate(fromDate) : ""}
              </Text>
              <FontAwesomeIcon
                icon={faCalendarDays}
                color={AppColors.secondary}
                size={14}
              />
            </Pressable>
          </View>

          {/* Ô Đến ngày */}
          <View className="flex-1">
            <Pressable
              onPress={() => setOpenToDate(true)}
              className="flex-row items-center justify-between bg-slate-50 border border-slate-200 rounded-xl px-3 h-12 active:bg-slate-100"
            >
              <Text className="text-slate-800 text-xs font-semibold">
                {toDate ? formatDate(toDate) : ""}
              </Text>
              <FontAwesomeIcon
                icon={faCalendarDays}
                color={AppColors.secondary}
                size={14}
              />
            </Pressable>
          </View>
        </View>
      </View>

      {/* Table Area */}
      <View className="flex-1">
        <GeneralTable
          data={list}
          columns={columns}
          selectedColumns={selectedColumns}
          onRowPress={(item) => handleEdit(item)}
          renderCell={renderCustomCell}
          getRowClassName={(item) =>
            item.Conclude === "K" ? "bg-amber-100" : ""
          }
        />
      </View>

      {/* Component Pagination */}
      <Pagination
        page={params.page}
        totalPage={totalPage}
        onPageChange={(newPage) =>
          setParams((prev) => ({ ...prev, page: newPage }))
        }
      />

      {/* User Selection Modal */}
      {userModal && (
        <UserModalList
          handleOpenUserModalList={() => setUserModal(false)}
          onSubmit={(selected: UserType) => {
            setParams((prev) => ({
              ...prev,
              owner: selected?.UserName ? String(selected.UserName) : "",
              username:
                selected.DisplayName ||
                selected.FullName ||
                selected.UserName ||
                "",
              page: 1,
            }));
            setUserModal(false);
          }}
          open={userModal}
          title="Chọn nhân viên"
        />
      )}

      {/* Date Pickers */}
      <DatePicker
        modal
        mode="date"
        open={openFromDate}
        date={fromDate ? new Date(fromDate) : new Date()}
        locale="vi"
        onConfirm={(date) => {
          setOpenFromDate(false);
          setFromDate(date);
          setParams((prev) => ({
            ...prev,
            fromDate: date,
            page: 1,
          }));
        }}
        title={"Từ ngày"}
        onCancel={() => setOpenFromDate(false)}
      />

      <DatePicker
        modal
        mode="date"
        open={openToDate}
        date={toDate ? new Date(toDate) : new Date()}
        locale="vi"
        onConfirm={(date) => {
          setOpenToDate(false);
          setToDate(date);
          setParams((prev) => ({
            ...prev,
            toDate: date,
            page: 1,
          }));
        }}
        title={"Đến ngày"}
        onCancel={() => setOpenToDate(false)}
      />
    </View>
  );
};

export default QualityControlList;
