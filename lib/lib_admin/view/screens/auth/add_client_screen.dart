import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/add_client_controller.dart';
import '../../../core/class/statusrequest.dart';
import '../../../core/constant/color.dart';
import '../../../core/constant/responsive.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/header.dart';
import '../../widgets/common/input_fields.dart';
import '../../widgets/common/main_button.dart';
import '../../widgets/common/client_card.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _clientsScrollController = ScrollController();
  String? _previousErrorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _clientsScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(AddClientControllerImp());
    return Scaffold(
      appBar: const CustomAppBar(title: 'Clients', showBackButton: true),
      body: SafeArea(
        child: Column(
          children: [
          Container(
            color: AppColor.backgroundColor,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColor.primaryColor,
              unselectedLabelColor: AppColor.textSecondaryColor,
              indicatorColor: AppColor.primaryColor,
              tabs: const [
                Tab(text: 'Add Client'),
                Tab(text: 'View Clients'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAddClientTab(context),
                _buildViewClientsTab(context),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildAddClientTab(BuildContext context) {
    return GetBuilder<AddClientControllerImp>(
      builder: (controller) {
        if (controller.errorMessage != null &&
            controller.errorMessage != _previousErrorMessage) {
          _previousErrorMessage = controller.errorMessage;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        } else if (controller.errorMessage == null) {
          _previousErrorMessage = null;
        }
        return SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: Responsive.padding(context),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Header(
                    title: "Add New Client",
                    subtitle: "Fill in the details to create a new client",
                    haveButton: false,
                  ),
                  if (controller.errorMessage != null)
                    _buildErrorMessage(
                      context,
                      controller,
                      controller.errorMessage!,
                    ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  Text(
                    "Client Information",
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 18),
                      fontWeight: FontWeight.bold,
                      color: AppColor.textColor,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildFormField(
                    context,
                    label: "Username",
                    hint: "Enter username",
                    controller: controller.usernameController,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildFormField(
                    context,
                    label: "Email",
                    hint: "Enter email address",
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  _buildFormField(
                    context,
                    label: "Password",
                    hint: "Enter password",
                    controller: controller.passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  Text(
                    "Status",
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, mobile: 14),
                      fontWeight: FontWeight.w500,
                      color: AppColor.textColor,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 8)),
                  _buildStatusDropdown(context, controller),
                  SizedBox(height: Responsive.spacing(context, mobile: 32)),
                  MainButton(
                    text: controller.isLoading ? "Creating..." : "Create Client",
                    onPressed: controller.isLoading
                        ? null
                        : controller.createClient,
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 16)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewClientsTab(BuildContext context) {
    return GetBuilder<AddClientControllerImp>(
      builder: (controller) {
        if (controller.clientsStatusRequest == StatusRequest.loading &&
            controller.clients.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          );
        }
        if ((controller.clientsStatusRequest == StatusRequest.serverFailure ||
                controller.clientsStatusRequest ==
                    StatusRequest.offlineFailure ||
                controller.clientsStatusRequest ==
                    StatusRequest.serverException ||
                controller.clientsStatusRequest ==
                    StatusRequest.timeoutException) &&
            controller.clients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColor.errorColor,
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 16)),
                Text(
                  'Failed to load clients',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 18),
                    fontWeight: FontWeight.bold,
                    color: AppColor.textColor,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 8)),
                Text(
                  'Please try again',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    color: AppColor.textSecondaryColor,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 24)),
                MainButton(
                  text: 'Retry',
                  onPressed: () => controller.refreshClients(),
                ),
              ],
            ),
          );
        }
        if (controller.clients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppColor.textSecondaryColor,
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 16)),
                Text(
                  'No clients found',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 18),
                    fontWeight: FontWeight.bold,
                    color: AppColor.textColor,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, mobile: 8)),
                Text(
                  'Create your first client',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, mobile: 14),
                    color: AppColor.textSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshClients();
          },
          color: AppColor.primaryColor,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!controller.isLoadingClients &&
                  controller.hasMore &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                controller.loadClients();
              }
              return false;
            },
            child: SingleChildScrollView(
              controller: _clientsScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: Responsive.padding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(
                      title: "All Clients",
                      subtitle: "View and manage all clients",
                      haveButton: false,
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                    ...controller.clients.map((client) => ClientCard(
                          client: client,
                          onLongPress: () => controller.deleteClient(client.id),
                        )),
                    if (controller.isLoadingClients)
                      Padding(
                        padding: EdgeInsets.all(
                          Responsive.spacing(context, mobile: 16),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ),
                    SizedBox(height: Responsive.spacing(context, mobile: 16)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, mobile: 14),
            fontWeight: FontWeight.w500,
            color: AppColor.textColor,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 8)),
        InputFields(
          controller: controller,
          hintText: hint,
          keyboardType: keyboardType,
          valid: (value) => null,
          obscureText: obscureText,
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(
    BuildContext context,
    AddClientControllerImp controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.borderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: controller.selectedStatus,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.spacing(context, mobile: 16),
            vertical: Responsive.spacing(context, mobile: 12),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        items: const [
          DropdownMenuItem(
            value: 'active',
            child: Text('Active'),
          ),
          DropdownMenuItem(
            value: 'disable',
            child: Text('Disable'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.selectedStatus = value;
            controller.update();
          }
        },
        style: TextStyle(
          fontSize: Responsive.fontSize(context, mobile: 14),
          color: AppColor.textColor,
        ),
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppColor.textColor,
        ),
      ),
    );
  }

  Widget _buildErrorMessage(
    BuildContext context,
    AddClientControllerImp controller,
    String message,
  ) {
    return Container(
      margin: EdgeInsets.only(
        bottom: Responsive.spacing(context, mobile: 16),
      ),
      padding: EdgeInsets.all(Responsive.spacing(context, mobile: 12)),
      decoration: BoxDecoration(
        color: AppColor.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColor.errorColor,
            size: 20,
          ),
          SizedBox(width: Responsive.spacing(context, mobile: 8)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColor.errorColor,
                fontSize: Responsive.fontSize(context, mobile: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
