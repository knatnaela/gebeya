'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Skeleton } from '@/components/ui/skeleton';
import { Plus, Edit, UserPlus, Shield, Mail, Building2 } from 'lucide-react';
import { toast } from 'sonner';
import { usePermissions } from '@/contexts/permissions-context';
import { useAuth } from '@/contexts/auth-context';

export default function UsersPage() {
  const queryClient = useQueryClient();
  const { canAccess } = usePermissions();
  const { user: currentUser } = useAuth();
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState<any>(null);

  // Form state
  const [email, setEmail] = useState('');
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [role, setRole] = useState<'PLATFORM_OWNER' | 'MERCHANT_ADMIN' | 'MERCHANT_STAFF'>('PLATFORM_OWNER');
  const [selectedRoleIds, setSelectedRoleIds] = useState<string[]>([]);
  const [companyId, setCompanyId] = useState<string>('');

  const { data: users, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const res = await apiClient.get('/users');
      return res.data.data || [];
    },
  });

  const { data: roles } = useQuery({
    queryKey: ['roles', 'PLATFORM_OWNER'],
    queryFn: async () => {
      const res = await apiClient.get('/roles?type=PLATFORM_OWNER');
      return res.data.data || [];
    },
  });

  const createMutation = useMutation({
    mutationFn: async (data: any) => {
      const res = await apiClient.post('/users', data);
      return res.data;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      setIsCreateDialogOpen(false);
      resetForm();
      toast.success('User created successfully. Temporary password sent via email.');
      // Optionally show temporary password
      if (data.data?.temporaryPassword) {
        toast.info(`Temporary password: ${data.data.temporaryPassword}`, { duration: 10000 });
      }
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to create user');
    },
  });

  const updateMutation = useMutation({
    mutationFn: async ({ id, data }: { id: string; data: any }) => {
      const res = await apiClient.put(`/users/${id}`, data);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      setIsEditDialogOpen(false);
      resetForm();
      toast.success('User updated successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to update user');
    },
  });

  const resetForm = () => {
    setEmail('');
    setFirstName('');
    setLastName('');
    setRole('PLATFORM_OWNER');
    setSelectedRoleIds([]);
    setCompanyId(currentUser?.companyId || '');
    setSelectedUser(null);
  };

  const handleCreate = () => {
    if (!email || !firstName) {
      toast.error('Email and first name are required');
      return;
    }

    createMutation.mutate({
      email,
      firstName,
      lastName,
      role,
      companyId: companyId || currentUser?.companyId,
      roleIds: selectedRoleIds,
    });
  };

  const handleEdit = (user: any) => {
    setSelectedUser(user);
    setEmail(user.email);
    setFirstName(user.firstName);
    setLastName(user.lastName || '');
    setRole(user.role);
    setSelectedRoleIds(user.roles?.map((r: any) => r.id) || []);
    setIsEditDialogOpen(true);
  };

  const handleUpdate = () => {
    if (!selectedUser || !firstName) {
      toast.error('First name is required');
      return;
    }

    updateMutation.mutate({
      id: selectedUser.id,
      data: {
        firstName,
        lastName,
        isActive: selectedUser.isActive,
        roleIds: selectedRoleIds,
      },
    });
  };

  const toggleRole = (roleId: string) => {
    if (selectedRoleIds.includes(roleId)) {
      setSelectedRoleIds(selectedRoleIds.filter((id) => id !== roleId));
    } else {
      setSelectedRoleIds([...selectedRoleIds, roleId]);
    }
  };

  if (!canAccess('users.view')) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Users</h1>
          <p className="text-muted-foreground">You do not have permission to view this page</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Platform Owner Users</h1>
          <p className="text-muted-foreground">Create and manage platform owner users</p>
        </div>
        {canAccess('users.create') && (
          <Dialog
            open={isCreateDialogOpen}
            onOpenChange={(open) => {
              setIsCreateDialogOpen(open);
              if (!open) resetForm();
            }}
          >
            <DialogTrigger asChild>
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                Create User
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-lg">
              <DialogHeader>
                <DialogTitle>Create New User</DialogTitle>
                <DialogDescription>
                  Create a new platform owner user. A temporary password will be generated and sent via email.
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input
                    id="email"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="user@example.com"
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="firstName">First Name</Label>
                  <Input
                    id="firstName"
                    value={firstName}
                    onChange={(e) => setFirstName(e.target.value)}
                    placeholder="John"
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="lastName">Last Name (Optional)</Label>
                  <Input
                    id="lastName"
                    value={lastName}
                    onChange={(e) => setLastName(e.target.value)}
                    placeholder="Doe"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="role">User Role</Label>
                  <Select value={role} onValueChange={(value: any) => setRole(value)}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="PLATFORM_OWNER">Platform Owner</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label>Assign Roles</Label>
                  <div className="border rounded-md p-4 max-h-48 overflow-y-auto space-y-2">
                    {roles?.map((role: any) => (
                      <label key={role.id} className="flex items-center gap-2 cursor-pointer">
                        <input
                          type="checkbox"
                          checked={selectedRoleIds.includes(role.id)}
                          onChange={() => toggleRole(role.id)}
                          className="rounded"
                        />
                        <div className="flex-1">
                          <div className="font-medium">{role.name}</div>
                          {role.description && (
                            <div className="text-sm text-muted-foreground">{role.description}</div>
                          )}
                        </div>
                      </label>
                    ))}
                    {(!roles || roles.length === 0) && (
                      <p className="text-sm text-muted-foreground">No roles available. Create roles first.</p>
                    )}
                  </div>
                </div>
                <Button onClick={handleCreate} disabled={createMutation.isPending} className="w-full">
                  {createMutation.isPending ? 'Creating...' : 'Create User'}
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        )}
      </div>

      <Card>
        <CardHeader>
          <CardTitle>All Users</CardTitle>
          <CardDescription>Platform owner users and their roles</CardDescription>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <Skeleton key={i} className="h-16 w-full" />
              ))}
            </div>
          ) : users && users.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>User</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Assigned Roles</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {users.map((user: any) => (
                  <TableRow key={user.id}>
                    <TableCell>
                      <div>
                        <div className="font-medium">{user.firstName} {user.lastName}</div>
                        <div className="text-sm text-muted-foreground flex items-center gap-1">
                          <Mail className="h-3 w-3" />
                          {user.email}
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">{user.role}</Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex flex-wrap gap-1">
                        {user.roles && user.roles.length > 0 ? (
                          user.roles.map((role: any) => (
                            <Badge key={role.id} variant="secondary" className="flex items-center gap-1">
                              <Shield className="h-3 w-3" />
                              {role.name}
                            </Badge>
                          ))
                        ) : (
                          <span className="text-sm text-muted-foreground">No roles assigned</span>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      {user.isActive ? (
                        <Badge className="bg-green-100 text-green-800">Active</Badge>
                      ) : (
                        <Badge variant="destructive">Inactive</Badge>
                      )}
                      {user.requiresPasswordChange && (
                        <Badge variant="outline" className="ml-2">Password Change Required</Badge>
                      )}
                    </TableCell>
                    <TableCell className="text-right">
                      {canAccess('users.edit') && (
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => handleEdit(user)}
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                      )}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <div className="text-center py-12">
              <UserPlus className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No users found</p>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Edit Dialog */}
      <Dialog
        open={isEditDialogOpen}
        onOpenChange={(open) => {
          setIsEditDialogOpen(open);
          if (!open) resetForm();
        }}
      >
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Edit User</DialogTitle>
            <DialogDescription>
              Update user information and role assignments
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="edit-firstName">First Name</Label>
              <Input
                id="edit-firstName"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
                placeholder="John"
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-lastName">Last Name</Label>
              <Input
                id="edit-lastName"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
                placeholder="Doe"
              />
            </div>
            <div className="space-y-2">
              <Label>Assign Roles</Label>
              <div className="border rounded-md p-4 max-h-48 overflow-y-auto space-y-2">
                {roles?.map((role: any) => (
                  <label key={role.id} className="flex items-center gap-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={selectedRoleIds.includes(role.id)}
                      onChange={() => toggleRole(role.id)}
                      className="rounded"
                    />
                    <div className="flex-1">
                      <div className="font-medium">{role.name}</div>
                      {role.description && (
                        <div className="text-sm text-muted-foreground">{role.description}</div>
                      )}
                    </div>
                  </label>
                ))}
              </div>
            </div>
            <Button onClick={handleUpdate} disabled={updateMutation.isPending} className="w-full">
              {updateMutation.isPending ? 'Updating...' : 'Update User'}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

