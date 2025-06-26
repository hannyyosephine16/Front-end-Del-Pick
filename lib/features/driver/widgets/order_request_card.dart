// lib/features/driver/widgets/order_request_card.dart - COMPLETE VERSION
import 'package:flutter/material.dart';
import 'package:del_pick/data/models/driver/driver_request_model.dart';
import 'package:del_pick/app/themes/app_colors.dart';

class OrderRequestCard extends StatelessWidget {
  final DriverRequestModel driverRequest;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onViewDetail;
  final bool isLoading;

  const OrderRequestCard({
    Key? key,
    required this.driverRequest,
    this.onAccept,
    this.onReject,
    this.onViewDetail,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Order Code & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    driverRequest.orderCode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 12),

            // Store Info
            if (driverRequest.storeName.isNotEmpty) ...[
              _buildInfoRow(
                Icons.store,
                'Toko',
                driverRequest.storeName,
              ),
              const SizedBox(height: 8),
            ],

            // Customer Info
            if (driverRequest.customerName.isNotEmpty) ...[
              _buildInfoRow(
                Icons.person,
                'Customer',
                driverRequest.customerName,
              ),
              const SizedBox(height: 4),
            ],

            if (driverRequest.customerPhone.isNotEmpty) ...[
              _buildInfoRow(
                Icons.phone,
                'Telepon',
                driverRequest.customerPhone,
              ),
              const SizedBox(height: 8),
            ],

            // Order Details
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.attach_money,
                    'Total',
                    _formatCurrency(driverRequest.orderTotal),
                    valueColor: Colors.green,
                    valueWeight: FontWeight.bold,
                  ),
                ),
                if (driverRequest.deliveryFee > 0) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.delivery_dining,
                      'Ongkir',
                      _formatCurrency(driverRequest.deliveryFee),
                      valueColor: Colors.blue,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Time Info
            _buildInfoRow(
              Icons.access_time,
              'Waktu',
              driverRequest.timeElapsedString,
              valueColor: Colors.grey,
            ),

            // Estimated Times (jika ada)
            if (driverRequest.hasEstimatedTimes) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.schedule,
                      'Pickup',
                      driverRequest.formattedEstimatedPickupTime,
                      valueColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.local_shipping,
                      'Delivery',
                      driverRequest.formattedEstimatedDeliveryTime,
                      valueColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],

            // Action Buttons
            if (driverRequest.canRespond || onViewDetail != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.black87,
              fontWeight: valueWeight ?? FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final buttons = <Widget>[];

    // View Detail Button
    if (onViewDetail != null) {
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onViewDetail,
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Detail'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      );
    }

    // Reject Button (hanya untuk pending requests)
    if (onReject != null && driverRequest.canReject) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 8));
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onReject,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Tolak'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      );
    }

    // Accept Button (hanya untuk pending requests)
    if (onAccept != null && driverRequest.canAccept) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 8));
      buttons.add(
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onAccept,
            icon: isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check, size: 16),
            label: Text(isLoading ? 'Processing...' : 'Terima'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      );
    }

    return Row(children: buttons);
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;

    switch (driverRequest.status) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange[700]!;
        break;
      case 'accepted':
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green[700]!;
        break;
      case 'rejected':
        backgroundColor = Colors.red.withOpacity(0.15);
        textColor = Colors.red[700]!;
        break;
      case 'expired':
        backgroundColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey[700]!;
        break;
      case 'completed':
        backgroundColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blue[700]!;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        driverRequest.statusDisplayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}
