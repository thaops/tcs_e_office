// enum NotificationType { leaveRequest, task, meeting }

// class NotificationUtils {
//   /// Map từ legacy type string (từ OneSignal old format)
//   static NotificationType? getNotificationType(String? type) {
//     switch (type) {
//       case 'leave':
//         return NotificationType.leaveRequest;
//       case 'task':
//         return NotificationType.task;
//       case 'meeting':
//         return NotificationType.meeting;
//       default:
//         return null;
//     }
//   }

//   /// Map từ source string (từ backend) sang NotificationType
//   /// Dùng cho backward compatibility với OneSignal
//   static NotificationType? getNotificationTypeFromSource(String? source) {
//     switch (source) {
//       case 'DocumentIn':
//       case 'DocumentOut':
//         return NotificationType.task; // Fallback cho document
//       case 'TaskAssign':
//       case 'TaskReceived':
//         return NotificationType.task;
//       case 'DayOff':
//         return NotificationType.leaveRequest;
//       default:
//         return null;
//     }
//   }
// }